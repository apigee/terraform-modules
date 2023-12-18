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
  env_group_internal_hostnames = { for name, _ in var.apigee_envgroups :
    name => "${name}-api.${trimsuffix(var.dns.domain, ".")}"
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
    "servicenetworking.googleapis.com",
    "dns.googleapis.com"
  ]
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.network
  subnets = [{
    name               = var.backend.subnet
    ip_cidr_range      = var.backend.subnet_cidr
    region             = var.backend.region
    secondary_ip_range = null
  }]
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
  }
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  project_id          = module.project.project_id
  apigee_environments = var.apigee_environments
  ax_region           = var.ax_region
  apigee_envgroups = {
    for name, env_group in var.apigee_envgroups : name => {
      hostnames = concat(env_group.hostnames, [local.env_group_internal_hostnames[name]])
    }
  }
  network          = module.vpc.network.id
  apigee_instances = var.apigee_instances
}

module "backend-example" {
  source     = "../../modules/development-backend"
  project_id = module.project.project_id
  name       = var.backend.name
  network    = module.vpc.self_link
  subnet     = module.vpc.subnet_self_links["${var.backend.region}/${var.backend.subnet}"]
  region     = var.backend.region
}

module "private-dns" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/dns?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.dns.name
  zone_config = {
    domain = var.dns.domain
    private = {
      client_networks = [module.vpc.self_link]
    }
  }
  recordsets = merge(
    { "A ${var.backend.name}" = { type = "A", ttl = 300, records = [module.backend-example.ilb_forwarding_rule_address] } },
    { for eg_name in keys(var.apigee_envgroups) : "A ${eg_name}-api" => { type = "A", ttl = 300, records = values(module.apigee-x-core.instance_endpoints) } }
  )
}

resource "google_service_networking_peered_dns_domain" "apigee" {
  project    = module.project.project_id
  name       = "apigee-dns-peering"
  network    = module.vpc.name
  dns_suffix = var.dns.domain
}

resource "google_compute_firewall" "allow-backend-ingress" {
  name          = "allow-backend-ingress"
  project       = module.project.project_id
  network       = module.vpc.self_link
  source_ranges = [var.peering_range]
  target_tags   = [var.backend.name]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
