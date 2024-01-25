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
  description = "Project id."
  type        = string
}

variable "region" {
  description = "GCP region where the service attachment should be created."
  type        = string
}

variable "name" {
  description = "Name for the service attachment."
  type        = string
}

variable "nat_subnets" {
  description = "One or more NAT subnets to be used for PSC."
  type        = list(string)
}

variable "target_service" {
  description = "Target Service for the service attachment e.g. a forwarding rule."
  type        = string
}

variable "apigee_organization" {
  description = "Apigee organization where the Endpoint Attachment should be added to. Apigee Organization ID should be prefixed with 'organizations/'"
  type        = string
  validation {
    condition     = can(regex("^(organizations/[a-zA-Z0-9-_]+)$", var.apigee_organization))
    error_message = "Invalid Apigee Organization ID. Please use the format \"organizations/[a-zA-Z0-9-_]+\"."
  }
}

variable "target_servers" {
  description = "Map of target servers to be created and associated with the endpoint attachment."
  default     = {}
  type = map(object({
    environment_id = string
    name           = string
    protocol       = optional(string, "HTTP")
    port           = optional(number, 80)
    enabled        = optional(bool, true)
    s_sl_info = optional(object({
      enabled                  = bool
      client_auth_enabled      = optional(bool, null)
      key_store                = optional(string, null)
      key_alias                = optional(string, null)
      trust_store              = optional(string, null)
      ignore_validation_errors = optional(bool, null)
      protocols                = optional(list(string), null)
      ciphers                  = optional(list(string), null)
      common_name = optional(object({
        value          = optional(string, null)
        wildcard_match = optional(bool, null)
      }))
    }))
  }))
}
