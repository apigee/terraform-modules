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

ax_region = "europe-west1"

apigee_environments = {
  test1 = {
    display_name = "Test 1"
    description  = "Environment created by apigee/terraform-modules"
    node_config  = null
    iam          = null
    envgroups    = ["test"]
  }
  test2 = {
    display_name = "Test 2"
    description  = "Environment created by apigee/terraform-modules"
    node_config  = null
    iam          = null
    envgroups    = ["test"]
  }
}

apigee_envgroups = {
  test = {
    hostnames = ["test.api.example.com"]
  }
}

subnets = [{
  name          = "hybrid-europe-west1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west1"
  secondary_ip_range = {
    pods     = "10.100.0.0/20"
    services = "10.101.0.0/23"
  }
}]

# POC settings to reduce infrastructure cost
# reconsider using these for production!
node_preemptible_runtime = true
node_locations_data      = ["europe-west1-b"]
