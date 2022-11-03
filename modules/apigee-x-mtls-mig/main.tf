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

module "mtls-proxy-sa" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v16.0.0"
  project_id = var.project_id
  name       = "apigee-mtls-proxy-vm"
}

module "config-bucket" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs?ref=v16.0.0"
  project_id = var.project_id
  name       = "apigee-mtls-ingress-${random_id.bucket.dec}"
  location   = "EU"
  iam = {
    "roles/storage.objectViewer" = ["serviceAccount:${module.mtls-proxy-sa.email}"]
  }
}

resource "google_storage_bucket_object" "envoy_config" {
  name    = "envoy-config.yaml"
  content = replace(file("${path.module}/envoy-config-template.yaml"), "#ENDPOINT_IP#", var.endpoint_ip)
  bucket  = module.config-bucket.name
}

resource "google_storage_bucket_object" "setup_script" {
  name    = "setup.sh"
  content = file("${path.module}/setup.sh")
  bucket  = module.config-bucket.name
}

resource "google_storage_bucket_object" "ca_cert" {
  name   = "cacert.pem"
  source = var.ca_cert_path
  bucket = module.config-bucket.name
}

resource "google_storage_bucket_object" "tls_cert" {
  name   = "servercert.pem"
  source = var.tls_cert_path
  bucket = module.config-bucket.name
}

resource "google_storage_bucket_object" "tls_key" {
  name   = "serverkey.pem"
  source = var.tls_key_path
  bucket = module.config-bucket.name
}

module "apigee-mtls-proxy-template" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm?ref=v16.0.0"
  project_id    = var.project_id
  name          = "apigee-nb-mtls-proxy"
  zone          = "${var.region}-b"
  instance_type = var.machine_type
  tags          = var.network_tags
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
    BUCKET             = module.config-bucket.name
    startup-script-url = "gs://${module.config-bucket.name}/setup.sh"
  }
  service_account        = module.mtls-proxy-sa.email
  service_account_scopes = ["cloud-platform"]
  depends_on = [
    google_storage_bucket_object.setup_script,
    google_storage_bucket_object.ca_cert,
    google_storage_bucket_object.tls_cert,
    google_storage_bucket_object.tls_key,
    google_storage_bucket_object.envoy_config,
    module.nat
  ]
}

module "apigee-mtls-proxy-mig" {
  source            = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig?ref=v16.0.0"
  project_id        = var.project_id
  location          = var.region
  regional          = true
  name              = "apigee-mtls-proxy-${var.region}"
  target_size       = var.target_size
  autoscaler_config = var.autoscaler_config
  named_ports = {
    https = 443
  }
  default_version = {
    instance_template = module.apigee-mtls-proxy-template.template.self_link
    name              = "default"
  }
}

module "nat" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=v16.0.0"
  project_id     = var.project_id
  region         = var.region
  name           = "nat-${var.region}"
  router_network = var.network
}
