/**
 * Copyright 2024 Google LLC
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

ax_region = "us-west1"

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

apigee_instances = {
  euw1-instance = {
    region       = "us-west1"
    environments = ["test1", "test2"]
  }
}
