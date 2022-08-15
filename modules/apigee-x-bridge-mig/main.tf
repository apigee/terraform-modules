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
  region_shorthand = {
    "northamerica-northeast1" = "nrtam-nrteast1",
    "northamerica-northeast2" = "nrtam-nrteast2",
    "southamerica-west1"      = "stham-west1",
    "southamerica-east1"      = "stham-east1",
    "europe-southwest1"       = "europe-sthwest1",
    "australia-southeast1"    = "au-stheast1",
    "australia-southeast2"    = "au-stheast2"
  } # Shorthands for regions with long names.
  bridge_name = var.name == null ? "apigee-${lookup(local.region_shorthand, var.region)}" : var.name
}

module "bridge-template" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v16.0.0"
  project_id    = var.project_id
  name          = local.bridge_name
  zone          = "${var.region}-b"
  tags          = var.network_tags
  instance_type = var.machine_type
  network_interfaces = [{
    network    = var.network,
    subnetwork = var.subnet
    nat        = false
    addresses  = null
    alias_ips  = null
  }]
  boot_disk = {
    image = "debian-cloud/debian-10"
    type  = "pd-standard"
    size  = 20
  }
  create_template = true
  metadata = {
    ENDPOINT           = var.endpoint_ip
    startup-script-url = "gs://apigee-5g-saas/apigee-envoy-proxy-release/latest/conf/startup-script.sh"
  }
  service_account_create = true
  service_account_scopes = ["cloud-platform"]
}

module "bridge-mig" {
  source      = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig?ref=v16.0.0"
  project_id  = var.project_id
  location    = var.region
  regional    = true
  name        = local.bridge_name
  target_size = 2
  default_version = {
    instance_template = module.bridge-template.template.self_link
    name              = "default"
  }
  named_ports = {
    https = 443
  }
  auto_healing_policies = {
    health_check      = module.bridge-mig.health_check.self_link
    initial_delay_sec = 30
  }
  health_check_config = {
    type = "https"
    check = {
      port         = 443,
      request_path = "/healthz/ingress"
    }
    config  = {}
    logging = false
  }
}

resource "google_compute_firewall" "allow_glb_to_mig_bridge" {
  name          = "hc-${local.bridge_name}"
  project       = split("/", "google_compute_network.${var.network}")[1]
  network       = var.network
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = var.network_tags
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
