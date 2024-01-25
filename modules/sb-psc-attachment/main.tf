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

resource "google_compute_service_attachment" "psc_service_attachment" {
  name        = var.name
  region      = var.region
  project     = var.project_id
  description = "A service attachment to be used by Apigee"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = var.nat_subnets
  target_service        = var.target_service
}

resource "google_apigee_endpoint_attachment" "endpoint_attachment" {
  org_id                 = var.apigee_organization
  endpoint_attachment_id = var.name
  location               = var.region
  service_attachment     = google_compute_service_attachment.psc_service_attachment.id
}


resource "google_apigee_target_server" "target_server" {
  for_each = var.target_servers

  name        = each.value.name
  description = "Target server for ${var.name} endpoint attachment"
  env_id      = each.value.environment_id
  protocol    = each.value.protocol
  host        = google_apigee_endpoint_attachment.endpoint_attachment.host
  port        = each.value.port
  is_enabled  = each.value.enabled

  dynamic "s_sl_info" {
    for_each = each.value.s_sl_info != null ? [1] : []
    content {
      enabled                  = each.value.s_sl_info.enabled
      client_auth_enabled      = each.value.s_sl_info.client_auth_enabled
      key_store                = each.value.s_sl_info.key_store
      key_alias                = each.value.s_sl_info.key_alias
      trust_store              = each.value.s_sl_info.trust_store
      ignore_validation_errors = each.value.s_sl_info.ignore_validation_errors
      protocols                = each.value.s_sl_info.protocols
      ciphers                  = each.value.s_sl_info.ciphers
      dynamic "common_name" {
        for_each = each.value.s_sl_info.common_name != null ? [1] : []
        content {
          value          = each.value.s_sl_info.common_name.value
          wildcard_match = each.value.s_sl_info.common_name.wildcard_match
        }
      }
    }
  }
}