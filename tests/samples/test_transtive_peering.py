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
from .utils import *

FIXTURES_DIR = os.path.join(
    os.path.dirname(__file__), "../../samples/x-transitive-peering"
)


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
    assert len(resources) == 60


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


def test_firewall_appliance(resources):
    "Test the firewall for network appliance"
    appliance_firewalls = [
        r["values"] for r in resources if r["name"] == "allow-appliance-ingress"
    ]
    assert len(appliance_firewalls) == 1
    assert set(appliance_firewalls[0]["source_ranges"]) == set(
        ["10.0.0.0/22", "10.200.0.0/28"]
    )
