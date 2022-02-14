/**
 * Copyright 2022 Google LLC
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
  subnet_region_name   = { for subnet in var.exposure_subnets :
    subnet.region => "${subnet.region}/${subnet.name}"
  }
  instance_region_name = { for subnet in var.exposure_subnets :
    subnet.region => subnet.instance
  }
  svpc_host_project_id = var.svpc_host_project_id != "" ? var.svpc_host_project_id : join("-", ["host", var.project_id])
}

module "host-project" {
  source                 = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v9.0.2"
  name                   = local.svpc_host_project_id
  parent                 = var.project_parent
  billing_account        = var.billing_account
  project_create         = var.project_create
  auto_create_network    = false
  shared_vpc_host_config = {
    enabled          = true
    service_projects = [] # defined later
  }
  services                  = [
    "serviceusage.googleapis.com"
  ]
}

module "service-project" {
  source                    = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v9.0.2"
  name                      = var.project_id
  parent                    = var.project_parent
  billing_account           = var.billing_account
  project_create            = var.project_create
  auto_create_network       = false
  shared_vpc_service_config = {
    attach       = true
    host_project = module.host-project.project_id
  }
  services                  = [
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

resource "google_project_service" "apigee" {
  project = module.service-project.project_id
  service = "apigee.googleapis.com"
}

resource "google_project_service" "svc_service_networking" {
  project = module.service-project.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "host_service_networking" {
  project = module.host-project.project_id
  service = "servicenetworking.googleapis.com"
}

module "shared-vpc" {
  source                      = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v9.0.2"
  project_id                  = module.host-project.project_id
  name                        = var.network
  psn_ranges                  = [var.peering_range]
  subnets                     = var.exposure_subnets
  shared_vpc_host             = true
  shared_vpc_service_projects = [
    module.service-project.project_id
  ]
  iam = {
    for subnet in var.exposure_subnets :
    "${subnet.region}/${subnet.name}" =>
    {
      "roles/compute.networkUser" = [
        "serviceAccount:${module.service-project.service_accounts.cloud_services}"
      ]
    }
  }
}

module "nip-development-hostname" {
  source             = "github.com/apigee/terraform-modules/modules/nip-development-hostname"
  project_id         = module.service-project.project_id
  address_name       = "apigee-external"
  subdomain_prefixes = [for name, _ in var.apigee_envgroups : name]
}

module "apigee-x-core" {
  source              = "github.com/apigee/terraform-modules/modules/apigee-x-core"
  project_id          = module.service-project.project_id
  ax_region           = var.ax_region
  apigee_instances    = var.apigee_instances
  apigee_environments = var.apigee_environments
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      environments = env_group.environments
      hostnames    = concat(env_group.hostnames, ["${name}.${module.nip-development-hostname.hostname}"])
    }
  }
  network = module.shared-vpc.network.id
  depends_on = [
    google_project_service.apigee,
    google_project_service.host_service_networking,
    google_project_service.svc_service_networking
  ]
}

module "apigee-x-bridge-mig" {
  for_each    = local.subnet_region_name
  source      = "github.com/apigee/terraform-modules/modules/apigee-x-bridge-mig"
  project_id  = module.service-project.project_id
  network     = module.shared-vpc.network.id
  region      = each.key
  subnet      = module.shared-vpc.subnet_self_links[local.subnet_region_name[each.key]]
  endpoint_ip = module.apigee-x-core.instance_endpoints[local.instance_region_name[each.key]]
}

module "mig-l7xlb" {
  source          = "github.com/apigee/terraform-modules/modules/mig-l7xlb"
  project_id      = module.service-project.project_id
  name            = "apigee-xlb"
  backend_migs    = [for _, mig in module.apigee-x-bridge-mig : mig.instance_group]
  ssl_certificate = module.nip-development-hostname.ssl_certificate
  external_ip     = module.nip-development-hostname.ip_address
}
