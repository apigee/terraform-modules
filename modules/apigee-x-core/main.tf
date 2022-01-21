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

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

module "kms-org-db" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v9.0.2"
  project_id = var.project_id
  key_iam = {
    org-db = {
      "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
    }
  }
  keyring = {
    location = var.ax_region
    name     = "apigee-x-org"
  }
  keys = {
    org-db = null
  }
}

module "apigee" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-organization?ref=v9.0.2"
  project_id              = var.project_id
  analytics_region        = var.ax_region
  runtime_type            = "CLOUD"
  authorized_network      = var.network
  database_encryption_key = module.kms-org-db.key_ids["org-db"]
  apigee_environments     = var.apigee_environments
  apigee_envgroups        = var.apigee_envgroups
  depends_on = [
    google_project_service_identity.apigee_sa,
    module.kms-org-db.id
  ]
}

module "kms-inst-disk" {
  for_each   = var.apigee_instances
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v9.0.2"
  project_id = var.project_id
  key_iam = {
    inst-disk = {
      "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
    }
  }
  keyring = {
    location = each.value.region
    name     = "apigee-${each.key}"
  }
  keys = {
    inst-disk = null
  }
}

module "apigee-x-instance" {
  for_each            = var.apigee_instances
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-x-instance?ref=v9.0.2"
  apigee_org_id       = module.apigee.org_id
  name                = each.key
  region              = each.value.region
  cidr_mask           = each.value.cidr_mask
  apigee_environments = each.value.environments
  disk_encryption_key = module.kms-inst-disk[each.key].key_ids["inst-disk"]
  depends_on = [
    google_project_service_identity.apigee_sa,
    module.kms-inst-disk.self_link
  ]
}
