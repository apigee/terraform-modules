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
  } # Configuration for PSC Subnet Region and Name mapping.
  apigee_l7ilb_regional_ingress_metadata = {
    for key, element in var.apigee_instances_metadata : element.apigee_instances.region => {
      l7_ilb_proxy_subnet_name       = element.l7_ilb_proxy_subnet_name
      l7_ilb_proxy_subnet_cidr_range = element.l7_ilb_proxy_subnet_cidr_range
      # l7_ilb_subnet_name             = element.l7_ilb_subnet_name
      # l7_ilb_subnet_cidr_range       = element.l7_ilb_subnet_cidr_range
      l7_ilb_name_prefix = element.l7_ilb_name_prefix
    }
  } # Map of objects for L7 ILB Regional Ingress for Apigee.
  apigee_instances = {
    for key, element in var.apigee_instances_metadata : key => {
      region       = element.apigee_instances.region
      ip_range     = element.apigee_instances.ip_range
      environments = element.apigee_instances.environments
    } # Map of objects for Apigee Instances.
  }
}

# GCP Project to host Apigee Organization and the related components.
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

# VPC Network to host Apigee Organization network resources.
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

# Module for creation of Apigee Organization and related Apigee resources.
module "apigee-x-core" {
  source     = "../../modules/apigee-x-core"
  project_id = module.project.project_id
  ax_region  = var.ax_region
  # billing_type        = "PAYG" # Mandatory for PAYG. Billing type of the Apigee Organization. Keep this as "PAYG" for Pay-As-You-Go Apigee Organization.
  apigee_environments = var.apigee_environments
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      hostnames = env_group.hostnames
    }
  }
  apigee_instances = local.apigee_instances
  network          = module.vpc.network.id
}

# VPC for Private Service Connect-based Ingress.
module "psc-ingress-vpc" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id              = module.project.project_id
  name                    = var.psc_ingress_network
  auto_create_subnetworks = false
  subnets                 = var.psc_ingress_subnets
}

# Resource for creating PSC NEG(s).
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.project_id
  for_each              = local.apigee_instances
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

# Module for creation of L7 ILB(s) with PSC NEG backend.
module "nb-psc-l7ilb" {
  for_each                       = local.apigee_l7ilb_regional_ingress_metadata
  source                         = "../../modules/nb-psc-l7ilb"
  project_id                     = module.project.project_id
  vpc_network_name               = module.psc-ingress-vpc.name
  region                         = each.key
  l7_ilb_proxy_subnet_name       = each.value.l7_ilb_proxy_subnet_name
  l7_ilb_proxy_subnet_cidr_range = each.value.l7_ilb_proxy_subnet_cidr_range
  l7_ilb_name_prefix             = each.value.l7_ilb_name_prefix
  l7_ilb_subnet_id               = module.psc-ingress-vpc.subnet_self_links[local.psc_subnet_region_name[each.key]]
  psc_neg                        = element([for _, psc_neg in google_compute_region_network_endpoint_group.psc_neg : psc_neg.id if length(regexall(".*${each.key}.*", psc_neg.self_link)) > 0], 0) # Getting the PSC NEG Endpoint ID for the PSC NEG corresponding to the region in which L7 ILB is being created.
}
