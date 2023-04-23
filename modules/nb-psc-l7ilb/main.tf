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

# Google Compute Network Data Source for getting the details of the VPC Network.
data "google_compute_network" "vpc_network" {
  name    = var.vpc_network_name # Name of the VPC Network.
  project = var.project_id       # ID of the GCP Project hosting the VPC Network.
}

# Configuration for setting up a Proxy-only Subnet for L7 ILB.
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = var.l7_ilb_proxy_subnet_name               # Name of the L7 ILB Proxy-only Subnet.
  project       = var.project_id                             # ID of the GCP Project that should host the Subnet.
  ip_cidr_range = var.l7_ilb_proxy_subnet_cidr_range         # IP CIDR Range for L7 ILB Proxy-only Subnet.
  region        = var.region                                 # Region in which the Subnet should be created.
  purpose       = "REGIONAL_MANAGED_PROXY"                   # Purpose of the Subnet denoting that the Subnet is a Proxy-only Subnet.
  role          = "ACTIVE"                                   # Role to denote whether the Subnet is Active or a Backup Subnet.
  network       = data.google_compute_network.vpc_network.id # VPC Network in which the Subnet should be created.
}

# Configuration for setting the Regional Backend Service for PSC.
resource "google_compute_region_backend_service" "psc_backend" {
  name                  = "${var.l7_ilb_name_prefix}-backend" # Name of the Regional Backend Service.
  project               = var.project_id                      # ID of the GCP Project that should host the Regional Backend Service.
  region                = var.region                          # Region in which the Regional Backend Service should be hosted.
  protocol              = "HTTPS"                             # The protocol which the Regional Backend Service should use to communicate with the backend.
  load_balancing_scheme = "INTERNAL_MANAGED"                  # The type of load balancing that this Regional Backend Service will be used for.
  backend {
    group          = var.psc_neg   # PSC NEG to be used as the backend.
    balancing_mode = "UTILIZATION" # Balancing mode for the PSC NEG backend.
  }                                # Configuration for the backends which serves this Regional Backend Service.
  lifecycle {
    create_before_destroy = true
  } # Lifecycle rule to tell Terraform to create a replacement object first before deleting this object in case of an update which cannot be done in-place.
}

# Configuration for setting the URL Map for the Regional Backend Service.
resource "google_compute_region_url_map" "url_map" {
  name            = "${var.l7_ilb_name_prefix}-url-map"                  # Name of the URL Map that should be created.
  project         = var.project_id                                       # ID of the GCP Project that should host the URL Map.
  region          = var.region                                           # Region in which the URL Map should be created.
  default_service = google_compute_region_backend_service.psc_backend.id # Backend Service to which the URL Map should be linked.
}

# Configuration for setting the HTTP Target Proxy for the URL Map.
resource "google_compute_region_target_http_proxy" "http_proxy" {
  name    = "${var.l7_ilb_name_prefix}-proxy"        # Name of the HTTP Target Proxy that should be created.
  project = var.project_id                           # ID of the GCP Project that should host the HTTP Target Proxy.
  region  = var.region                               # Region in which the HTTP Target Proxy should be created.
  url_map = google_compute_region_url_map.url_map.id # URL Map that should be linked to the HTTP Target Proxy.
}

# Configuration for setting the Forwarding Rule for the HTTP Target Proxy.
resource "google_compute_forwarding_rule" "forwarding_rule" {
  name                  = "${var.l7_ilb_name_prefix}-fr"                        # Name of the Forwarding Rule that should be created.
  project               = var.project_id                                        # ID of the GCP Project that should host the Forwarding Rule.
  region                = var.region                                            # Region in which the Forwarding Rule should be created.
  target                = google_compute_region_target_http_proxy.http_proxy.id # Target HTTP Target Proxy for the Forwarding Rule.
  ip_protocol           = "TCP"                                                 # IP Protocol which applies to the Load Balancing Forwarding Rule.
  port_range            = "80"                                                  # Port on which the Forwarding Rule will be listening to forward the packets to the target.
  load_balancing_scheme = "INTERNAL_MANAGED"                                    # Signifies the usage type for the Forwarding Rule.
  allow_global_access   = true                                                  # Configuration for Global Access for L7 ILB.
  labels                = var.labels                                            # Labels for the Forwarding Rule, if any.
  network               = data.google_compute_network.vpc_network.id            # VPC Network in which the Forwarding Rule should be created.
  # subnetwork            = google_compute_subnetwork.l7ilb_subnet.id             # Subnet in which the Forwarding Rule should be created.
  subnetwork   = var.l7_ilb_subnet_id # Subnet in which the Forwarding Rule should be created.
  network_tier = "PREMIUM"            # Network Tier for the VPC in which the Forwarding Rule should be created.
}
