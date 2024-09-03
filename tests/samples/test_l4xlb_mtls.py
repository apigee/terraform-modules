# Copyright 2022 Google LLC
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
from .utils import *

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), "../../samples/x-l4xlb-mtls")


@pytest.fixture(scope="module")
def resources(recursive_plan_runner):
    _, resources = recursive_plan_runner(
        FIXTURES_DIR,
        tf_var_file=os.path.join(FIXTURES_DIR, "x-demo.tfvars"),
        project_id="testonly",
        project_create="true"
    )
    return resources


def test_resource_count(resources):
    "Test total number of resources created."
    assert len(resources) == 53


def test_apigee_instance(resources):
    "Test Apigee Instance Resource"
    assert_instance(resources, "europe-west1", "10.0.0.0/22")


def test_apigee_instance_attachment(resources):
    "Test Apigee Instance Attachments."
    assert_instance_attachment(resources, ["europe-west1-test1", "europe-west1-test2"])

def test_envgroup_attachment(resources):
    "Test Apigee Envgroup Attachments."
    assert_envgroup_attachment(resources, ["test1", "test2"])


def test_envgroup(resources):
    "Test env group."
    assert_envgroup_name(resources, "test")

def test_named_ports_match(resources):
    migBackendMatches = [r for r in resources if r['address'] == 'module.mig-l4xlb.google_compute_backend_service.mig_backend']
    instanceGroups = [r for r in resources if r['address'] == 'module.apigee-x-mtls-mig["euw1-instance"].module.apigee-mtls-proxy-mig.google_compute_region_instance_group_manager.default[0]']
    assert len(migBackendMatches) == 1
    assert len(instanceGroups) == 1
    assert migBackendMatches[0]['values']['port_name'] == instanceGroups[0]['values']['named_port'][0]['name']
