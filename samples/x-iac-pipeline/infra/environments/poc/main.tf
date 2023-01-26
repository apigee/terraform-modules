# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "infra" {
  source              = "../../"
  apigee_project_id   = var.apigee_project_id
  host_project_id     = var.host_project_id
  billing_account     = var.billing_account
  ax_region           = var.ax_region
  apigee_environments = var.apigee_environments
  apigee_instances    = var.apigee_instances
  apigee_envgroups    = var.apigee_envgroups
  network             = var.network
  exposure_subnets    = var.exposure_subnets
  peering_range       = var.peering_range
  support_range       = var.support_range
  project_create      = var.project_create
  project_parent      = var.project_parent
}
