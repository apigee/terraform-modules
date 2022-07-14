/**
 * Copyright 2022 Google LLC
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

variable "project_id" {
  description = "Project id (also used for the Apigee Organization)."
  type        = string
}

variable "ax_region" {
  description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "List of Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "billing_account" {
  description = "Billing account id."
  type        = string
  default     = null
}

variable "project_parent" {
  description = "Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format."
  type        = string
  default     = null
  validation {
    condition     = var.project_parent == null || can(regex("(organizations|folders)/[0-9]+", var.project_parent))
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "project_create" {
  description = "Create project. When set to false, uses a data source to reference existing project."
  type        = bool
  default     = false
}

variable "network" {
    description = "Network name to be used for hosting the Apigee hybrid cluster."
    type = string
    default = "apigee-network"
}

variable "subnets" {
  description = "Subnets to be greated in the network."
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = []
}

variable "cluster_region" {
    description = "Region for where to create the cluster."
    type = string
}

variable "cluster_location" {
    description = "Region/Zone for where to create the cluster."
    type = string
}

variable "gke_cluster" {
  description = "GKE Cluster Specification"
  type = object({
    name = string
    region = string
    location = string
    master_ip_cidr = string
    master_authorized_ranges = map(string)
    secondary_range_pods = string
    secondary_range_services = string
  })
  default = {
    location = "europe-west1"
    master_authorized_ranges = {
      "intenret" = "0.0.0.0/0"
    }
    master_ip_cidr = "192.168.0.0/28"
    name =  "hybrid-cluster"
    region = "europe-west1"
    secondary_range_pods = "pods"
    secondary_range_services = "services"
  }
}