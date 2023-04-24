/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
variable "gcp_service_list" {
  description             = "The list of required Google apis"
  type                    = list(string)
  default                 = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "dns.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each                = toset(var.gcp_service_list)
  project                 = var.gcp_project_id
  service                 = each.key
  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "docker-main" {
  location                = var.gcp_region
  repository_id           = var.repository_id
  description             = "Main Docker Repository for Cloud Run"
  format                  = "DOCKER"
  depends_on              = [ 
    google_project_service.gcp_services
  ]
}

resource "null_resource" "login_image_build" {
    triggers              = {
        always_run        = timestamp()
    }

    provisioner "local-exec" {
        working_dir       = "${path.module}/services/login"
        command           = "gcloud builds submit --tag ${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/docker-main/login"
    }

    depends_on = [
      google_artifact_registry_repository.docker-main
    ]
}

resource "null_resource" "search_image_build" {
    triggers              = {
        always_run        = timestamp()
    }

    provisioner "local-exec" {
        working_dir       = "${path.module}/services/search"
        command           = "gcloud builds submit --tag ${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/docker-main/search"
    }

    depends_on = [
      google_artifact_registry_repository.docker-main
    ]
}

resource "null_resource" "translate_image_build" {
    triggers              = {
        always_run        = timestamp()
    }

    provisioner "local-exec" {
        working_dir       = "${path.module}/services/translate"
        command           = "gcloud builds submit --tag ${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/docker-main/translate"
    }

    depends_on = [
      google_artifact_registry_repository.docker-main
    ]
}

module "cloud_run" {
  source                  = "GoogleCloudPlatform/cloud-run/google"
  version                 = "~> 0.2.0"

  #3 Cloud Run internal services 
  for_each                = toset([
    "login",
    "search",
    "translate"
  ])

  # Required variables
  service_name            = each.key
  project_id              = var.gcp_project_id
  location                = var.gcp_region
  image                   = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/docker-main/${each.key}"
  service_annotations     = {
    "run.googleapis.com/ingress": "internal"
  }

  depends_on = [
    google_project_service.gcp_services,
    null_resource.login_image_build,
    null_resource.search_image_build,
    null_resource.translate_image_build
  ]

}

# VPC network
resource "google_compute_network" "default" {
  name                    = "l7-ilb-network"
  auto_create_subnetworks = false
}

# Proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  name                    = "l7-ilb-proxy-subnet"
  ip_cidr_range           = "10.0.0.0/24"
  region                  = var.gcp_region
  purpose                 = "REGIONAL_MANAGED_PROXY"
  role                    = "ACTIVE"
  network                 = google_compute_network.default.id
}

# Backend subnet
resource "google_compute_subnetwork" "default" {
  name                    = "l7-ilb-subnet"
  ip_cidr_range           = "10.0.1.0/24"
  region                  = var.gcp_region
  network                 = google_compute_network.default.id
}

# Reserved internal address
resource "google_compute_address" "default" {
  name                    = "l7-ilb-ip"
  subnetwork              = google_compute_subnetwork.default.id
  address_type            = "INTERNAL"
  address                 = "10.0.1.5"
  region                  = var.gcp_region
  project                 = var.gcp_project_id
}

# Regional forwarding rule
resource "google_compute_forwarding_rule" "default" {
  project                 = var.gcp_project_id
  name                    = "psc-l7-ilb-forwarding-rule"
  region                  = var.gcp_region
  depends_on              = [google_compute_subnetwork.proxy_subnet]
  ip_address              = google_compute_address.default.id
  load_balancing_scheme   = "INTERNAL_MANAGED"
  port_range              = "443"
  target                  = google_compute_region_target_https_proxy.default.id
  network                 = google_compute_network.default.id
  subnetwork              = google_compute_subnetwork.default.id
  network_tier            = "PREMIUM"
}

# Self-signed regional SSL certificate for testing
resource "tls_private_key" "default" {
  algorithm               = "RSA"
  rsa_bits                = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem         = tls_private_key.default.private_key_pem

  # Certificate expires after 100 days.
  validity_period_hours   = 2400

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours     = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  dns_names               = ["internal.example.com"]
  subject {
    common_name           = "internal.example.com"
    organization          = "Exo, Inc"
  }
}

resource "google_compute_region_ssl_certificate" "default" {
  name_prefix             = "exco-sslcert-"
  private_key             = tls_private_key.default.private_key_pem
  certificate             = tls_self_signed_cert.default.cert_pem
  region                  = var.gcp_region
  lifecycle {
    create_before_destroy = true
  }
}

# Regional target HTTPS proxy
resource "google_compute_region_target_https_proxy" "default" {
  name                    = "l7-ilb-target-https-proxy"
  region                  = var.gcp_region
  url_map                 = google_compute_region_url_map.https_lb.id
  ssl_certificates        = [google_compute_region_ssl_certificate.default.self_link]
}

# Regional URL map
resource "google_compute_region_url_map" "https_lb" {
  name                    = "l7-ilb-regional-url-map"
  region                  = var.gcp_region
  default_service         = google_compute_region_backend_service.default.id
}

resource "google_compute_region_backend_service" "default" {
  load_balancing_scheme   = "INTERNAL_MANAGED"
  backend {
    group                 = google_compute_region_network_endpoint_group.cloudrun_neg.id
    balancing_mode        = "UTILIZATION"
  }
  region                  = var.gcp_region
  name                    = "region-backend-service"
  protocol                = "HTTPS"
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                    = "cloudrun-neg"
  network_endpoint_type   = "SERVERLESS"
  region                  = var.gcp_region
  cloud_run {
    url_mask              = var.url_mask
  }
}

resource "google_compute_subnetwork" "psc_ilb_nat" {
  name                    = "psc-ilb-nat"
  region                  = var.gcp_region
  network                 = google_compute_network.default.id
  purpose                 = "PRIVATE_SERVICE_CONNECT"
  ip_cidr_range           = "10.75.0.0/28"
}

resource "google_compute_service_attachment" "psc_ilb_service_attachment" {
  name                    = "psc-attachment-ilb"
  region                  = var.gcp_region
  description             = "Service attachment for ilb configured with Terraform"
  project                 = var.gcp_project_id
  enable_proxy_protocol   = false
  connection_preference   = "ACCEPT_AUTOMATIC"
  nat_subnets             = [google_compute_subnetwork.psc_ilb_nat.id]
  target_service          = google_compute_forwarding_rule.default.id
}

resource "google_apigee_endpoint_attachment" "endpoint_attachment" {
  org_id                  = "organizations/${var.gcp_project_id}"
  endpoint_attachment_id  = var.apigee_endpoint_attachment
  location                = var.gcp_region
  service_attachment      = google_compute_service_attachment.psc_ilb_service_attachment.id
}

# Service account used by apigee apiproxy to invoke a cloud run app using id token
resource "google_service_account" "service_account_apiproxy" {
  account_id              = "apigee-apiproxy"
  display_name            = "invoke cloud run app from apigee apiproxy"
}

locals {
    service_account_a     = "serviceAccount:apigee-apiproxy@${var.gcp_project_id}.iam.gserviceaccount.com"
  }

resource "google_project_iam_member" "sa_apigee_apiproxy" {
  for_each                = toset([
    "roles/run.invoker"
  ])
  role                    = each.key
  project                 = var.gcp_project_id
  member                  = local.service_account_a
  depends_on              = [google_service_account.service_account_apiproxy]
}

resource "google_dns_managed_zone" "private-zone-apigee" {
  name                    = "private-zone-apigee"
  dns_name                = "example.com."
  description             = "ExCo private DNS zone (Apigee)"
  visibility              = "private"
  private_visibility_config {
    networks {
      network_url         = "projects/${var.gcp_project_id}/global/networks/${var.consumer_vpc}"
    }
  }
  depends_on = [ 
    google_project_service.gcp_services
  ]
}

resource "google_dns_managed_zone" "private-zone-ilb" {
  name                    = "private-zone-ilb"
  dns_name                = "example.com."
  description             = "ExCo private DNS zone (L7 ILB)"
  visibility              = "private"
  private_visibility_config {
    networks {
      network_url         = "projects/${var.gcp_project_id}/global/networks/l7-ilb-network"
    }
  }
  depends_on = [ 
    google_project_service.gcp_services
  ]
}

resource "google_dns_record_set" "a-apigee" {
  name                    = "internal.${google_dns_managed_zone.private-zone-apigee.dns_name}"
  managed_zone            = google_dns_managed_zone.private-zone-apigee.name
  type                    = "A"
  ttl                     = 300
  rrdatas                 = [google_apigee_endpoint_attachment.endpoint_attachment.host]
}

resource "google_dns_record_set" "a-ilb" {
  name                    = "internal.${google_dns_managed_zone.private-zone-ilb.dns_name}"
  managed_zone            = google_dns_managed_zone.private-zone-ilb.name
  type                    = "A"
  ttl                     = 300
  rrdatas                 = ["10.0.1.5"]
}

resource "google_service_networking_peered_dns_domain" "apigee" {
  project                 = var.gcp_project_id
  name                    = "apigee-dns-peering"
  network                 = var.consumer_vpc
  dns_suffix              = google_dns_managed_zone.private-zone-apigee.dns_name
}
