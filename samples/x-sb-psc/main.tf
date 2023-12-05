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
  name       = var.network
  subnets    = []
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
  apigee_envgroups    = var.apigee_envgroups
  network             = module.vpc.network.id
  apigee_instances    = var.apigee_instances
}

module "backend-vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = module.project.project_id
  name       = var.backend_network
  subnets = [
    var.backend_subnet,
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

resource "google_compute_subnetwork" "psc_nat_subnet" {
  name          = var.backend_psc_nat_subnet.name
  project       = module.project.project_id
  region        = var.backend_region
  network       = module.backend-vpc.network.id
  ip_cidr_range = var.backend_psc_nat_subnet.ip_cidr_range
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

module "southbound-psc" {
  source              = "../../modules/sb-psc-attachment"
  project_id          = module.project.project_id
  name                = var.psc_name
  region              = var.backend_region
  apigee_organization = module.apigee-x-core.org_id
  nat_subnets         = [google_compute_subnetwork.psc_nat_subnet.id]
  target_service      = module.backend-example.ilb_forwarding_rule_self_link
  depends_on = [
    module.apigee-x-core.instance_endpoints
  ]
}

resource "google_compute_firewall" "allow_psc_nat_to_backend" {
  name          = "psc-nat-to-demo-backend"
  project       = module.project.project_id
  network       = module.backend-vpc.network.id
  source_ranges = [var.backend_psc_nat_subnet.ip_cidr_range]
  target_tags   = [var.backend_name]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}
