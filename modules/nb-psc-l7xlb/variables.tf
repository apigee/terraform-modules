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

variable "psc_service_attachments" {
  description = "Map of region to service attachment ID (currently only one map entry is allowed)."
  type        = map(string)
  default     = {}
}

variable "ssl_certificate" {
  description = "SSL certificate for the HTTPS LB."
  type        = string
}

variable "external_ip" {
  description = "External IP for the L7 XLB."
  type        = string
  default     = null
}

variable "name" {
  description = "External LB name."
  type        = string
}

variable "neg_single_region" {
  description = "Apigee instance to use for NEG (can only be one at this point)."
  type        = string
}

variable "network" {
  description = "Network for the PSC NEG"
  type        = string
}

variable "subnet" {
  description = "Subnetwork for the PSC NEG"
  type        = string
}
