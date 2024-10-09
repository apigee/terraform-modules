/**
 * Copyright 2024 Google LLC
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
  description = "Project ID."
  type        = string
}

variable "vpc_name" {
  description = "Project ID."
  type        = string
}

variable "project_parent" {
  description = "Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format."
  type        = string
  validation {
    condition     = var.project_parent == null || can(regex("(organizations|folders)/[0-9]+", var.project_parent))
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "billing_account" {
  description = "Billing account ID."
  type        = string
}

variable "billing_type" {
  description = "Billing type of the Apigee organization."
  type        = string
  default     = null
}

variable "project_create" {
  description = "Create project. When set to false, uses a data source to reference existing project."
  type        = bool
  default     = false
}

variable "project_services" {
  description = "List of services to enable in the project."
  type        = list(string)
  default = [
    "apigee.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

variable "ax_region" {
  description = "GCP region for storing Apigee analytics data."
  type        = string
}

variable "apigee_environments" {
  description = "Apigee Environments."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    node_config = optional(object({
      min_node_count = optional(number)
      max_node_count = optional(number)
    }))
    iam       = optional(map(list(string)))
    envgroups = list(string)
    type      = optional(string)
  }))
  default = null
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    hostnames = list(string)
  }))
  default = null
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL orgs)."
  type = map(object({
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = null
}

variable "exposure_subnets" {
  description = "Subnets for exposing Apigee services"
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    instance           = string
    secondary_ip_range = map(string)
  }))
  default = []
}

variable "psc_subnets" {
  description = "Subnets for psc endpoints"
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    instance           = string
    secondary_ip_range = map(string)
  }))
  default = []
}

variable "lb_name" {
  description = "Name of the load balancer."
  type        = string
}


variable "ssl_crt_domains" {
  description = "Domains for the managed SSL certificate."
  type        = list(string)
}

variable "peering_range" {
  description = "Peering CIDR range"
  type        = string
}

variable "support_range1" {
  description = "Support CIDR range of length /28 (required by Apigee for troubleshooting purposes)."
  type        = string
}

