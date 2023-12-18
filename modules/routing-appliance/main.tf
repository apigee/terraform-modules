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

resource "random_id" "bucket" {
  byte_length = 8
}

module "appliance-sa" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v28.0.0"
  project_id = var.project_id
  name       = "sa-${var.name}"
}

module "config-bucket" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs?ref=v28.0.0"
  project_id = var.project_id
  name       = "appliance-${random_id.bucket.dec}"
  location   = "EU"
  iam = {
    "roles/storage.objectViewer" = ["serviceAccount:${module.appliance-sa.email}"]
  }
}

resource "google_storage_bucket_object" "setup_script" {
  name    = "setup.sh"
  content = file("${path.module}/setup.sh")
  bucket  = module.config-bucket.name
}

module "routing-appliance-template" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v28.0.0"
  project_id     = var.project_id
  name           = var.name
  zone           = "${var.region}-b"
  instance_type  = var.machine_type
  tags           = [var.name]
  can_ip_forward = true
  network_interfaces = [{
    network    = var.network,
    subnetwork = var.subnet
    nat        = true
    addresses  = null
    alias_ips  = null
  }]
  boot_disk = {
    initialize_params = {
      image = "projects/debian-cloud/global/images/family/debian-11"
      type  = "pd-standard"
      size  = 10
    }
  }
  create_template = true
  metadata = {
    startup-script-url = "gs://${module.config-bucket.name}/setup.sh"
  }
  service_account = {
    email  = module.appliance-sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_storage_bucket_object.setup_script
  ]
}

module "routing-appliance-mig" {
  source            = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig?ref=v28.0.0"
  project_id        = var.project_id
  location          = var.region
  name              = "${var.name}-${var.region}"
  target_size       = 2
  instance_template = module.routing-appliance-template.template.self_link
}

module "ilb-appliance" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-lb-int?ref=v28.0.0"
  project_id    = var.project_id
  region        = var.region
  name          = var.name
  service_label = var.name
  vpc_config = {
    network    = var.network
    subnetwork = var.subnet
  }
  forwarding_rules_config = {
    "" = {
      ports = [443]
    }
  }
  backends = [
    {
      group          = module.routing-appliance-mig.group_manager.instance_group,
      failover       = false
      balancing_mode = "CONNECTION"
    }
  ]
  health_check_config = {
    tcp = { port = 80 }
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

resource "google_compute_route" "appliance" {
  for_each     = var.forwarded_ranges
  project      = var.project_id
  name         = "appliance-rt-${each.key}"
  dest_range   = each.value.range
  network      = var.network
  next_hop_ilb = module.ilb-appliance.forwarding_rules[""].id
  priority     = each.value.priority
}
