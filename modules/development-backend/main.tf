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

module "demo-backend-template" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v16.0.0"
  project_id    = var.project_id
  name          = var.name
  zone          = "${var.region}-b"
  instance_type = var.machine_type
  tags          = [var.name]
  network_interfaces = [{
    network    = var.network,
    subnetwork = var.subnet
    nat        = false
    addresses  = null
    alias_ips  = null
  }]
  boot_disk = {
    image = "projects/debian-cloud/global/images/family/debian-11"
    type  = "pd-standard"
    size  = 10
  }
  create_template = true
  metadata = {
    startup-script = "sudo mkdir -p /var/www && cd /var/www && echo 'hello from demo' > index.html && python3 -m http.server 80"
  }
  service_account_create = true
  service_account_scopes = ["cloud-platform"]
}

module "demo-backend-mig" {
  source      = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig?ref=v16.0.0"
  project_id  = var.project_id
  location    = var.region
  regional    = true
  name        = "${var.name}-${var.region}"
  target_size = 2
  default_version = {
    instance_template = module.demo-backend-template.template.self_link
    name              = "default"
  }
}

module "ilb-backend" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb?ref=v16.0.0"
  project_id    = var.project_id
  region        = var.region
  name          = var.name
  service_label = var.name
  network       = var.network
  subnetwork    = var.subnet
  ports         = [80]
  backends = [
    {
      group          = module.demo-backend-mig.group_manager.instance_group,
      failover       = false
      balancing_mode = "CONNECTION"
    }
  ]
  health_check_config = {
    type    = "tcp"
    check   = { port = 80 }
    config  = {}
    logging = false
  }
}

resource "google_compute_firewall" "hc-allow" {
  name          = "allow-hc-${var.name}"
  project       = var.project_id
  network       = var.network
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = [var.name]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
