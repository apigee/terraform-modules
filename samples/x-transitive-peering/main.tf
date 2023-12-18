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
  name       = var.apigee_network
  subnets    = [var.appliance_subnet]
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
    export_routes = true
    import_routes = false
  }
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  project_id          = module.project.project_id
  ax_region           = var.ax_region
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
  apigee_instances    = var.apigee_instances
  network             = module.vpc.network.id
}

module "routing-appliance" {
  source           = "../../modules/routing-appliance"
  project_id       = module.project.project_id
  name             = var.appliance_name
  network          = module.vpc.name
  subnet           = module.vpc.subnet_self_links["${var.appliance_subnet.region}/${var.appliance_subnet.name}"]
  region           = var.appliance_region
  forwarded_ranges = var.appliance_forwarded_ranges
}

resource "google_compute_firewall" "allow-appliance-ingress" {
  name          = "allow-appliance-ingress"
  project       = module.project.project_id
  network       = module.vpc.self_link
  source_ranges = [var.peering_range, var.backend_subnet.ip_cidr_range]
  target_tags   = [var.appliance_name]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

module "backend-vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.backend_network
  subnets    = [var.backend_subnet]
}

module "peering-apigee-backend" {
  source = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc-peering?ref=v28.0.0"
  prefix = "peering-apigee-backend"

  local_network = module.vpc.self_link
  peer_network  = module.backend-vpc.self_link

  routes_config = {
    local = {
      export = true
    }
  }

  depends_on = [
    module.backend-vpc,
    module.vpc
  ]
}

module "backend-example" {
  source     = "../../modules/development-backend"
  project_id = module.project.project_id
  name       = var.backend_name
  network    = module.backend-vpc.network.id
  subnet     = module.backend-vpc.subnet_self_links["${var.backend_subnet.region}/${var.backend_subnet.name}"]
  region     = var.backend_region
}

resource "google_compute_firewall" "allow-backend-ingress" {
  name          = "allow-backend-ingress"
  project       = module.project.project_id
  network       = module.backend-vpc.self_link
  source_ranges = [var.appliance_subnet.ip_cidr_range]
  target_tags   = [var.backend_name]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

