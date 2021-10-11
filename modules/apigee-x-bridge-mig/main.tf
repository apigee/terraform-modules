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

module "bridge-template" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v6.0.0"
  project_id = var.project_id
  name       = "apigee-${var.region}"
  zone       = "${var.region}-b"
  tags       = var.bridge_tags
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
  create_template  = true
  metadata = {
    ENDPOINT           = var.endpoint_ip
    startup-script-url = "gs://apigee-5g-saas/apigee-envoy-proxy-release/latest/conf/startup-script.sh"
  }
  service_account_create = true
  service_account_scopes = ["cloud-platform"]
}

module "bridge-mig" {
  source      = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig?ref=v6.0.0"
  project_id  = var.project_id
  location    = var.region
  regional    = true
  name        = "apigee-bridge-mig-${var.region}"
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
    type    = "https"
    check   = {
        port = 443,
        request_path = "/healthz/ingress"
    }
    config  = {}
    logging = false
  }
}

resource "random_id" "fw" {
  byte_length = 4
}

resource "google_compute_firewall" "allow_glb_to_mig_bridge" {
  name          = "allow-glb-bridge-${random_id.fw.hex}"
  project       = var.project_id
  network       = var.network
  source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
  target_tags   = var.bridge_tags
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}