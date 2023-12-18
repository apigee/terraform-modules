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

locals {
  psc_subnet_region_name = { for subnet in var.psc_ingress_subnets :
    subnet.region => "${subnet.region}/${subnet.name}"
  }
}

module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v28.0.0"
  name            = var.project_id
  parent          = var.project_parent
  billing_account = var.billing_account
  project_create  = var.project_create
  services = [
    "apigee.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.network
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
  }
}

module "nip-development-hostname" {
  source             = "../../modules/nip-development-hostname"
  project_id         = module.project.project_id
  address_name       = "apigee-external"
  subdomain_prefixes = [for name, _ in var.apigee_envgroups : name]
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  billing_type        = "PAYG"
  project_id          = module.project.project_id
  ax_region           = var.ax_region
  apigee_environments = var.apigee_environments
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      hostnames = concat(env_group.hostnames, ["${name}.${module.nip-development-hostname.hostname}"])
    }
  }
  apigee_instances = var.apigee_instances
  network          = module.vpc.network.id
}

module "psc-ingress-vpc" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id              = module.project.project_id
  name                    = var.psc_ingress_network
  auto_create_subnetworks = false
  subnets                 = var.psc_ingress_subnets
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.project_id
  for_each              = var.apigee_instances
  name                  = "psc-neg-${each.value.region}"
  region                = each.value.region
  network               = module.psc-ingress-vpc.network.id
  subnetwork            = module.psc-ingress-vpc.subnet_self_links[local.psc_subnet_region_name[each.value.region]]
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = module.apigee-x-core.instance_service_attachments[each.value.region]
  lifecycle {
    create_before_destroy = true
  }
}

module "nb-psc-l7xlb" {
  source          = "../../modules/nb-psc-l7xlb"
  project_id      = module.project.project_id
  name            = "apigee-xlb-psc"
  ssl_certificate = [module.nip-development-hostname.ssl_certificate]
  external_ip     = module.nip-development-hostname.ip_address
  psc_negs        = [for _, psc_neg in google_compute_region_network_endpoint_group.psc_neg : psc_neg.id]
}
