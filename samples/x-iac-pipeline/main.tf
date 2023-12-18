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

module "bootstrap-project" {
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v28.0.0"
  name                = var.project_id
  parent              = var.project_parent
  billing_account     = var.billing_account
  project_create      = var.project_create
  auto_create_network = false
  services = [
    "apigee.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "storage.googleapis.com"
  ]
}

module "infra-tfstate-bucket" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs?ref=v28.0.0"
  project_id    = module.bootstrap-project.project_id
  name          = "${var.project_id}-infra-tfstate"
  location      = var.region
  storage_class = "REGIONAL"
  iam = {
  }
}

module "app-tfstate-bucket" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs?ref=v28.0.0"
  project_id    = module.bootstrap-project.project_id
  name          = "${var.project_id}-app-tfstate"
  location      = var.region
  storage_class = "REGIONAL"
  iam = {
  }
}

resource "google_sourcerepo_repository" "infra" {
  project = module.bootstrap-project.project_id
  name    = "infra-repo"
}

resource "google_sourcerepo_repository" "app" {
  project = module.bootstrap-project.project_id
  name    = "app-repo"
}

resource "google_cloudbuild_trigger" "app_trigger" {
  project  = module.bootstrap-project.project_id
  name     = "app-trigger"
  filename = "cloudbuild.yaml"
  trigger_template {
    branch_name = var.environment
    repo_name   = google_sourcerepo_repository.app.name
  }
  substitutions = {
    _TF_BUCKET  = "${module.bootstrap-project.project_id}-app-tfstate"
    _APIGEE_ORG = var.apigee_project_id
    _APIGEE_ENV = "test1"
  }
}

resource "google_cloudbuild_trigger" "infra_trigger" {
  project  = module.bootstrap-project.project_id
  name     = "infra-trigger"
  filename = "cloudbuild.yaml"
  trigger_template {
    branch_name = var.environment
    repo_name   = google_sourcerepo_repository.infra.name
  }
  substitutions = {
    _TF_BUCKET         = "${module.bootstrap-project.project_id}-infra-tfstate"
    _APIGEE_PROJECT_ID = var.apigee_project_id
    _HOST_PROJECT_ID   = var.host_project_id
    _PROJECT_PARENT    = var.project_parent
    _BILLING_ID        = var.billing_account
  }
}

resource "google_organization_iam_member" "org_project_creator" {
  count  = var.project_create && length(regexall("(organizations)/([0-9]+)", coalesce(var.project_parent, " "))) > 0 ? 1 : 0
  org_id = regex("(organizations)/([0-9]+)", var.project_parent)[1]
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "folder_project_creator" {
  count  = var.project_create && length(regexall("(folders)/([0-9]+)", coalesce(var.project_parent, " "))) > 0 ? 1 : 0
  folder = var.project_parent
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "org_xpn_admin" {
  count  = var.project_create && length(regexall("(organizations)/([0-9]+)", coalesce(var.project_parent, " "))) > 0 ? 1 : 0
  org_id = regex("(organizations)/([0-9]+)", var.project_parent)[1]
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

data "google_folder" "bootstrap_folder" {
  count               = var.project_create && length(regexall("(folders)/([0-9]+)", coalesce(var.project_parent, " "))) > 0 ? 1 : 0
  folder              = var.project_parent
  lookup_organization = true
}

resource "google_organization_iam_member" "folder_xpn_admin" {
  count  = var.project_create && length(regexall("(folders)/([0-9]+)", coalesce(var.project_parent, " "))) > 0 ? 1 : 0
  org_id = regex("(organizations)/([0-9]+)", data.google_folder.bootstrap_folder[0].organization)[1]
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_billing_account_iam_member" "billing_user" {
  count              = var.project_create ? 1 : 0
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "apigee_project_owner" {
  count   = var.project_create ? 0 : 1
  project = var.apigee_project_id
  role    = "roles/owner"
  member  = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "host_project_owner" {
  count   = var.project_create ? 0 : 1
  project = var.host_project_id
  role    = "roles/owner"
  member  = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

data "google_project" "host_project" {
  count      = var.project_create ? 0 : 1
  project_id = var.host_project_id
}

resource "google_organization_iam_member" "existing_org_xpn_admin" {
  count  = !var.project_create && (length(data.google_project.host_project) > 0 ? data.google_project.host_project[0].org_id : "") != "" ? 1 : 0
  org_id = data.google_project.host_project[0].org_id
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "folder_xpn_admin" {
  count  = !var.project_create && (length(data.google_project.host_project) > 0 ? data.google_project.host_project[0].folder_id : "") != "" ? 1 : 0
  folder = "folders/${data.google_project.host_project[0].folder_id}"
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${module.bootstrap-project.number}@cloudbuild.gserviceaccount.com"
}
