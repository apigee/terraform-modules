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
  subnets    = [var.firewall_appliance_subnet]
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
    export_routes = true
    import_routes = true
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

module "nat" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=v28.0.0"
  project_id     = module.project.project_id
  region         = var.firewall_appliance_subnet.region
  name           = "nat"
  router_network = module.vpc.name
}

resource "google_compute_route" "egress_via_firewall" {
  project           = module.project.project_id
  name              = "egress-via-fw"
  dest_range        = "0.0.0.0/0"
  network           = module.vpc.name
  next_hop_instance = module.mock-firewall.instance.id
  priority          = 800
}

resource "google_compute_route" "firewall_to_internet" {
  project          = module.project.project_id
  name             = "egress-for-fw-only"
  dest_range       = "0.0.0.0/0"
  network          = module.vpc.name
  next_hop_gateway = "default-internet-gateway"
  tags             = var.firewall_appliance_tags
  priority         = 750
}

module "mock-firewall" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v28.0.0"
  project_id     = module.project.project_id
  zone           = var.firewall_appliance_zone
  can_ip_forward = true
  name           = "mock-fw"
  network_interfaces = [{
    network    = module.vpc.name
    subnetwork = module.vpc.subnet_self_links["${var.firewall_appliance_subnet.region}/${var.firewall_appliance_subnet.name}"]
    nat        = false
    addresses  = null
  }]
  tags = var.firewall_appliance_tags
  service_account = {
    auto_create = true
    scopes      = ["cloud-platform"]
  }
  metadata = {
    startup-script = "sysctl -w net.ipv4.ip_forward=1 && iptables -t nat -A POSTROUTING -j MASQUERADE"
  }
}

resource "google_compute_firewall" "allow_glb_to_mig_bridge" {
  name          = "egress-fw-http-internal"
  project       = module.project.project_id
  network       = module.vpc.name
  source_ranges = [var.peering_range]
  target_tags   = var.firewall_appliance_tags
  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }
}
