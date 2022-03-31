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
  description = "GCP Project id."
  type        = string
}

variable "name" {
  description = "Name of the Example Backend."
  type        = string
  default     = "demo-backend"
}

variable "network" {
  description = "VPC network for running the MIGs (needs to be peered with the Apigee tenant project)."
  type        = string
}

variable "subnet" {
  description = "VPC subnet for running the MIGs"
  type        = string
}

variable "region" {
  description = "GCP Region for the MIGs."
  type        = string
}

variable "machine_type" {
  description = "GCE Machine type."
  type        = string
  default     = "e2-small"
}
