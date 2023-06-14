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

output "instance_group" {
  description = "Backend Service MIG."
  value       = module.demo-backend-mig.group_manager.instance_group
}

output "ilb_forwarding_rule_address" {
  description = "ILB forwarding rule IP address."
  value       = module.ilb-backend.forwarding_rule_address
}

output "ilb_forwarding_rule_self_link" {
  description = "ILB forwarding rule self link."
  value       = module.ilb-backend.forwarding_rule_self_link
}

output "region" {
  description = "Backend Service region."
  value       = module.ilb-backend.forwarding_rule.region
}
