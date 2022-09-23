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

output "endpoint_attachment_host" {
  description = "Host for the endpoint attachment to be used in Apigee."
  value       = google_apigee_endpoint_attachment.endpoint_attachment.host
}

output "endpoint_attachment_connection_state" {
  description = "Underlying connection state for the endpoint attachment."
  value       = google_apigee_endpoint_attachment.endpoint_attachment.connection_state
}
