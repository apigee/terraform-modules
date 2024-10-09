/**
 * Copyright 2024 Google LLC
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

locals {
  subnet_region_name = { for subnet in var.exposure_subnets :
    subnet.region => "${subnet.region}/${subnet.name}"
  }
  psc_subnets = { for psc in var.psc_subnets : 
    psc.name => psc 
  }
  region_psc_map = {for psc  in var.psc_subnets : 
    psc.region => psc.name 
  }

}

module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v28.0.0"
  name            = var.project_id
  parent          = var.project_parent
  billing_account = var.billing_account
  project_create  = var.project_create
  services        = var.project_services
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.vpc_name
  subnets    = [
    for subnet in concat(var.exposure_subnets, var.psc_subnets) :
    {
      "name"                = subnet.name
      "region"              = subnet.region
      "secondary_ip_ranges" = subnet.secondary_ip_range
      "ip_cidr_range"       = subnet.ip_cidr_range
    }
  ]
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range   
      apigee-support-range1 = var.support_range1
      
      #add_more_support_ranges_per_instance_region
    }
  }
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  project_id          = module.project.project_id
  billing_type        = var.billing_type
  ax_region           = var.ax_region
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
  apigee_instances    = var.apigee_instances
  network             = module.vpc.network.id
}


resource "google_compute_address" "psc_endpoint_address" {
  for_each = local.psc_subnets
  name         = "psc-ip-${each.value.region}"
  project      = module.project.project_id
  address_type = "INTERNAL"
  subnetwork   = module.vpc.subnet_self_links["${each.value.region}/${each.value.name}"]
  region       = each.value.region
}

resource "google_compute_forwarding_rule" "psc_ilb_consumer" {
  for_each = local.psc_subnets
  name                  = "psc-ea-${each.value.region}"
  project               = module.project.project_id
  region                = each.value.region
  target                = module.apigee-x-core.instance_service_attachments[each.value.region]
  load_balancing_scheme = ""
  network               = module.vpc.network.id
  ip_address            = google_compute_address.psc_endpoint_address[each.value.name].id
  depends_on = [
    google_compute_address.psc_endpoint_address,
    module.apigee-x-core
  ]
}

data "google_compute_address" "int_psc_ips" {
  for_each = google_compute_address.psc_endpoint_address
  name = each.value.name
  region = each.value.region
  project = module.project.project_id
}

module "apigee-x-bridge-mig" {
  for_each    = local.subnet_region_name
  source      = "../../modules/apigee-x-bridge-mig"
  project_id  = module.project.project_id
  network     = module.vpc.network.id
  region      = each.key
  subnet      = module.vpc.subnet_self_links[local.subnet_region_name[each.key]]
  endpoint_ip = data.google_compute_address.int_psc_ips[local.region_psc_map[each.key]].address
}

resource "google_compute_global_address" "external_address" {
  name         = "lb-${var.lb_name}-ip"
  project      = module.project.project_id
  address_type = "EXTERNAL"
}

data "google_compute_global_address" "my_lb_external_address" {
  name    = google_compute_global_address.external_address.name
  project = module.project.project_id
}

resource "google_compute_managed_ssl_certificate" "google_cert" {
  project = var.project_id
  name    = "ssl-cert"
  managed {
    domains = var.ssl_crt_domains
  }
}

module "mig-l7xlb" {
  source          = "../../modules/mig-l7xlb"
  project_id      = module.project.project_id
  name            = var.lb_name
  backend_migs    = [for _, mig in module.apigee-x-bridge-mig : mig.instance_group]
  ssl_certificate = [google_compute_managed_ssl_certificate.google_cert.id]
  external_ip     = data.google_compute_global_address.my_lb_external_address.address
}