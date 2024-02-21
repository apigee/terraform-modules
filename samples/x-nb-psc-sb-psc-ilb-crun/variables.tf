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
 
variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to create the gcp resources in."
}
 
variable "gcp_region" {
  type        = string
  description = "The GCP region to create the gcp resources in."
}
 
variable "gcp_zone" {
  type        = string
  description = "The GCP zone to create the gcp resources in."
}

variable "repository_id" {
  type        = string
  description = "Repository id of the artifact registry."
}

variable "url_mask" {
  type        = string
  description = "URL mask of the serverless network endpoint group (neg)."
}

variable "apigee_endpoint_attachment" {
  type        = string
  description = "Apigee endpoint attachment value."
}

variable "consumer_vpc" {
  type        = string
  description = "Consumer VPC network name."
}