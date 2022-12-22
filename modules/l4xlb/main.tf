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

resource "google_compute_health_check" "mig_lb_hc" {
  project = var.project_id
  name    = "${var.name}-hc"
  tcp_health_check {
    port = "443"
  }
}

resource "google_compute_backend_service" "mig_backend" {
  project       = var.project_id
  name          = "${var.name}-backend"
  port_name     = "https"
  protocol      = "TCP"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.mig_lb_hc.id]
  dynamic "backend" {
    for_each = var.backend_migs
    content {
      group           = backend.value
      balancing_mode  = "UTILIZATION"
      max_utilization = 1.0
      capacity_scaler = 1.0
    }
  }
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project    = var.project_id
  name       = "${var.name}-forwarding-rule"
  target     = google_compute_target_tcp_proxy.proxy.id
  ip_address = var.external_ip != null ? var.external_ip : null
  port_range = "443"
  labels     = var.labels
}

resource "google_compute_target_tcp_proxy" "proxy" {
  project         = var.project_id
  name            = "${var.name}-tcp-proxy"
  backend_service = google_compute_backend_service.mig_backend.id
}
