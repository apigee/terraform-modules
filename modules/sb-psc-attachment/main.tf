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
