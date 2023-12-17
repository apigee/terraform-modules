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

apigee_instances = {
  euw1-instance = {
    region       = "europe-west1"
    ip_range     = "10.0.0.0/22"
    environments = ["test1", "test2"]
  }
}

apigee_environments = {
  test1 = {
    display_name = "Test 1"
    description  = "Environment created by apigee/terraform-modules"
    node_config  = null
    iam          = null
    envgroups    = ["test"]
    type         = null
  }
  test2 = {
    display_name = "Test 2"
    description  = "Environment created by apigee/terraform-modules"
    node_config  = null
    iam          = null
    envgroups    = ["test"]
    type         = null
  }
}

apigee_envgroups = {
  test = {
    hostnames = ["test.api.example.com"]
  }
}

apigee_network   = "apigee-network"
peering_range    = "10.0.0.0/22"
support_range    = "10.1.0.0/28"
appliance_region = "europe-west1"
appliance_subnet = {
  name               = "appliance-euw1"
  ip_cidr_range      = "10.100.0.0/28"
  region             = "europe-west1"
  secondary_ip_range = null
}

backend_network = "backend-network"
backend_region  = "europe-west1"
backend_subnet = {
  name               = "backend-euw1"
  ip_cidr_range      = "10.200.0.0/28"
  region             = "europe-west1"
  secondary_ip_range = null
}

appliance_forwarded_ranges = {
  backend-routes = {
    range    = "10.200.0.0/27"
    priority = 800
  }
  apigee-routes = {
    range    = "10.0.0.0/21"
    priority = 800
  }
}
