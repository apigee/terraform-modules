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

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), "../../samples/x-iac-pipeline")


@pytest.fixture(scope="module")
def resources(recursive_plan_runner):
    _, resources = recursive_plan_runner(
        FIXTURES_DIR,
        tf_var_file=os.path.join(FIXTURES_DIR, "x-demo.tfvars"),
        project_id="boottestonly",
        apigee_project_id="apigeetestonly",
        host_project_id="hosttestonly",
        billing_account="testaccount",
        project_create="true"
    )
    return resources


def test_resource_count(resources):
    "Test total number of resources created."
    assert len(resources) == 24
