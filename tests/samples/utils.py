# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def assert_envgroup_attachment(resources, envs):
  "Test Apigee Envgroup Attachments."
  attachments = [r['values'] for r in resources if r['type']
              == 'google_apigee_envgroup_attachment']
  assert len(attachments) == 2
  assert set(a['environment'] for a in attachments) == set(envs)

def assert_envgroup_name(resources, name):
  "Test env group."
  envgroups = [r['values'] for r in resources if r['type']
          == 'google_apigee_envgroup']
  assert len(envgroups) == 1
  assert envgroups[0]['name'] == name

def assert_instance(resources, location, cidr):
  "Test Apigee Instance Resource"
  instances = [r['values'] for r in resources if r['type'] == 'google_apigee_instance']
  assert len(instances) == 1
  assert instances[0]['location'] == location
  assert instances[0]['peering_cidr_range'] == cidr

def assert_instance_attachment(resources, envs):
  "Test Apigee Instance Attachments."
  attachments = [r['values'] for r in resources if r['type']
              == 'google_apigee_instance_attachment']
  assert len(attachments) == 2
  assert set(a['environment'] for a in attachments) == set(envs)