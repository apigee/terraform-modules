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

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v6.0.0"
  project_id = var.project_id
  name       = var.apigee_network
  private_service_networking_range = var.peering_range
  subnets = [var.appliance_subnet]
}

module "apigee-x-core" {
  source              = "../../modules/apigee-x-core"
  project_id          = var.project_id
  ax_region           = var.ax_region
  apigee_instances    = var.apigee_instances
  apigee_environments = var.apigee_environments
  apigee_envgroups    = {
    for name, env_group in var.apigee_envgroups: name => {
      environments = env_group.environments
      hostnames = env_group.hostnames
    }
  }
  network = module.vpc.network.id
}

resource "google_compute_network_peering_routes_config" "peering_primary_routes" {
  project              = var.project_id
  peering              = "servicenetworking-googleapis-com"
  network              = module.vpc.name
  import_custom_routes = false
  export_custom_routes = true
}

module "routing-appliance" {
  source              = "../../modules/routing-appliance"
  project_id          = var.project_id
  name                = var.appliance_name
  network             = module.vpc.name
  subnet              = module.vpc.subnet_self_links["${var.appliance_subnet.region}/${var.appliance_subnet.name}"]
  region              = var.appliance_region
  forwarded_ranges    = var.appliance_forwarded_ranges
}

resource "google_compute_firewall" "allow-appliance-ingress" {
  name          = "allow-appliance-ingress"
  project       = var.project_id
  network       = module.vpc.self_link
  source_ranges = [var.peering_range, var.backend_subnet.ip_cidr_range]
  target_tags   = [var.appliance_name]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

module "backend-vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v6.0.0"
  project_id = var.project_id
  name       = var.backend_network
  subnets = [var.backend_subnet]
}

module "peering-apigee-backend" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc-peering?ref=v6.0.0"
  prefix        = "peering-apigee-backend"
  export_local_custom_routes = true

  local_network = module.vpc.self_link
  peer_network  = module.backend-vpc.self_link

  depends_on = [
    module.backend-vpc,
    module.vpc
  ]
}

module "backend-example" {
  source              = "../../modules/httpbin-development-backend"
  project_id          = var.project_id
  name                = var.backend_name
  network             = var.backend_network
  subnet              = module.backend-vpc.subnet_self_links["${var.backend_subnet.region}/${var.backend_subnet.name}"]
  region              = var.backend_region
}

resource "google_compute_firewall" "allow-backend-ingress" {
  name          = "allow-backend-ingress"
  project       = var.project_id
  network       = module.backend-vpc.self_link
  source_ranges = [var.appliance_subnet.ip_cidr_range]
  target_tags   = [var.backend_name]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

