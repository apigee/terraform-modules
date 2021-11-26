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

ax_region = "europe-west1"

apigee_environments = ["test1", "test2"]

apigee_envgroups = {
  test = {
    environments = ["test1", "test2"]
    hostnames    = ["test.api.example.com"] // + ${group_name}-api.internal
  }
}

apigee_instances = {
  euw1-instance = {
    region       = "europe-west1"
    cidr_mask    = 22
    environments = ["test1", "test2"]
  }
}

backend = {
  name        = "httpbin"
  region      = "europe-west1"
  subnet      = "demo-backend"
  subnet_cidr = "10.100.0.0/24"
}

dns = {
  name             = "intenal-dns"
  domain           = "internal."
}

network = "apigee-network"

peering_range = "10.0.0.0/22"
