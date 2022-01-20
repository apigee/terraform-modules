/**
 * Copyright 2021 Google LLC
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
  host_project_id = var.host_project_id != "" ? var.host_project_id : var.project_id
  service_project_id = var.service_project_id != "" ? var.service_project_id : var.project_id
}

module "hostProject" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v9.0.2"
  name            = local.host_project_id
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

module "serviceProject" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v9.0.2"
  name            = local.service_project_id
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
  source                           = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v9.0.2"
  project_id                       = module.hostProject.project_id
  name                             = var.network
  psn_ranges                       = [var.peering_range]
  subnets                          = var.exposure_subnets
}

module "nip-development-hostname" {
  source             = "../../modules/nip-development-hostname"
  project_id         = module.serviceProject.project_id
  address_name       = "apigee-external"
  subdomain_prefixes = [for name, _ in var.apigee_envgroups : name]
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  project_id          = module.serviceProject.project_id
  ax_region           = var.ax_region
  apigee_instances    = var.apigee_instances
  apigee_environments = var.apigee_environments
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      environments = env_group.environments
      hostnames    = concat(env_group.hostnames, ["${name}.${module.nip-development-hostname.hostname}"])
    }
  }
  network = module.vpc.network.id
}

module "apigee-x-bridge-mig" {
  for_each            = var.apigee_instances
  source              = "../../modules/apigee-x-bridge-mig"
  host_project_id     = module.hostProject.project_id
  service_project_id  = module.serviceProject.project_id
  network             = module.vpc.network.id
  subnet              = module.vpc.subnet_self_links[local.subnet_region_name[each.value.region]]
  region              = each.value.region
  endpoint_ip         = module.apigee-x-core.instance_endpoints[each.key]
}

module "mig-l7xlb" {
  source          = "../../modules/mig-l7xlb"
  project_id      = module.serviceProject.project_id
  name            = "apigee-xlb"
  backend_migs    = [for _, mig in module.apigee-x-bridge-mig : mig.instance_group]
  ssl_certificate = module.nip-development-hostname.ssl_certificate
  external_ip     = module.nip-development-hostname.ip_address
}
