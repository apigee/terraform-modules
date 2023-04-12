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

variable "ssl_certificate" {
  description = "A list of SSL certificates for the HTTPS LB."
  type        = list(string)
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

variable "security_policy" {
  description = "(Optional) The security policy associated with this backend service."
  type        = string
  default     = null
}

variable "psc_negs" {
  description = "List of PSC NEGs to be used as backends."
  type        = list(string)
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
  An optional map of label key:value pairs to assign to the forwarding rule.
  Default is an empty map.
  EOD
}
