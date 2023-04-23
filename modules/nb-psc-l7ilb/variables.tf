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

variable "project_id" {
  description = "ID of the GCP Project."
  type        = string
}

variable "vpc_network_name" {
  description = "Name of the VPC Network."
  type        = string
}

variable "region" {
  description = "GCP Region in which the resources should be created."
  type        = string
}

variable "l7_ilb_proxy_subnet_name" {
  description = "Name of the L7 ILB Proxy-only Subnet."
  type        = string
  default     = "l7ilb-proxy-subnet"
}

variable "l7_ilb_proxy_subnet_cidr_range" {
  description = "IP CIDR Range for the L7 ILB Proxy-only Subnet."
  type        = string
}

variable "l7_ilb_subnet_id" {
  description = "Subnet in which the Forwarding Rule should be created."
  type        = string
}

variable "l7_ilb_name_prefix" {
  description = "Prefix for the Load Balancer resources."
  type        = string
}

variable "psc_neg" {
  description = "PSC NEG to be used as backend."
  type        = string
}

variable "labels" {
  description = <<-EOD
  An optional map of label key:value pairs to assign to the forwarding rule.
  Default is an empty map.
  EOD
  type        = map(string)
  default     = {}
}
