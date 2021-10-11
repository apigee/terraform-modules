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


import os
import pytest

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), '../../../samples/x-l7xlb')

@pytest.fixture(scope="module")
def resources(recursive_plan_runner):
  _, resources = recursive_plan_runner(
    FIXTURES_DIR,
    tf_var_file=os.path.join(FIXTURES_DIR, "x-demo.tfvars"),
    project_id='testonly',
  )
  return resources

def test_resource_count(resources):
  "Test total number of resources created."
  assert len(resources) == 33


def test_envgroup_attachment(resources):
  "Test Apigee Envgroup Attachments."
  attachments = [r['values'] for r in resources if r['type']
              == 'google_apigee_envgroup_attachment']
  assert len(attachments) == 2
  assert set(a['environment'] for a in attachments) == set(['test1', 'test2'])


def test_envgroup(resources):
  "Test env group."
  envgroups = [r['values'] for r in resources if r['type']
          == 'google_apigee_envgroup']
  assert len(envgroups) == 1
  assert envgroups[0]['name'] == 'test'

def test_instance_bidge_location_parity(resources):
  "Test that the instance and bridge VM are in the same location"
  instance = [r['values'] for r in resources if r['type'] == 'google_apigee_instance'][0]
  instance_group_mgr = [r['values'] for r in resources if r['type'] == 'google_compute_region_instance_group_manager'][0]
  assert instance['location'] == instance_group_mgr['region']