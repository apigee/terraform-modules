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

variable "apigee_environments" {
  description = "Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "apigee_instances" {
  description = "Apigee Instances (only one for EVAL)."
  type = map(object({
    region       = string
    cidr_mask    = number
    environments = list(string)
  }))
  default = {}
}
variable "apigee_network" {
  description = "Apigee VPC name."
  type        = string
}

variable "appliance_name" {
  description = "Name for the routing appliance"
  type        = string
  default     = "routing-appliance"
}

variable "appliance_region" {
  description = "GCP Region for Routing Appliance (ensure this matches appliance_subnet.region)."
  type        = string
}

variable "appliance_subnet" {
  description = "Subnet to host the routing appliance"
  type = object({
    name          = string
    ip_cidr_range = string
    region        = string
    secondary_ip_range = map(string)
  })
}

variable "backend_name" {
  description = "Name for the Demo Backend"
  type        = string
  default     = "demo-backend"
}

variable "backend_network" {
  description = "Peered Backend VPC name."
  type        = string
}

variable "backend_region" {
  description = "GCP Region Backend (ensure this matches backend_subnet.region)."
  type        = string
}

variable "backend_subnet" {
  description = "Subnet to host the backend service"
  type = object({
    name          = string
    ip_cidr_range = string
    region        = string
    secondary_ip_range = map(string)
  })
}

variable "appliance_forwarded_ranges" {
  description = "CDIR ranges that should route via the network appliance"
  type = map(object({
    range     = string
    priority  = number
  }))
  default  = {}
}

variable "peering_range" {
  description = "Peering CIDR range"
  type = string
}