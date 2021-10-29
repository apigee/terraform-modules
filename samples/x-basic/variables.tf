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

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL orgs)."
  type = map(object({
    region       = string
    cidr_mask    = number
    environments = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "List of Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "network" {
  description = "Name of the VPC network to peer with the Apigee tennant project."
  type        = string
}

variable "peering_range" {
  description = "Service Peering CIDR range."
  type        = string
}
