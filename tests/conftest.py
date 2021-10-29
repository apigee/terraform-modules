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

"Shared fixtures"

import os
import pytest
import tftest

BASEDIR = os.path.dirname(os.path.dirname(__file__))


@pytest.fixture(scope="session")
def _plan_runner():
    "Returns a function to run Terraform plan on a fixture."

    def run_plan(fixture_path, tf_var_file=None, targets=None, refresh=True, **tf_vars):
        "Runs Terraform plan and returns parsed output."
        tf = tftest.TerraformTest(
            fixture_path, BASEDIR, os.environ.get("TERRAFORM", "terraform")
        )
        tf.setup()
        return tf.plan(
            output=True,
            refresh=refresh,
            tf_vars=tf_vars,
            tf_var_file=tf_var_file,
            targets=targets,
        )

    return run_plan


def recursive_resources(module):
    if "child_modules" in module:
        child_resources = [
            recursive_resources(child_module)
            for child_module in module["child_modules"]
        ]
    else:
        child_resources = []

    flattened_child_resources = [i for l in child_resources for i in l]

    if "resources" not in module:
        return flattened_child_resources
    return module["resources"] + flattened_child_resources


@pytest.fixture(scope="session")
def recursive_plan_runner(_plan_runner):
    "Returns a function to run Terraform plan on a module fixture."

    def run_plan(fixture_path, tf_var_file=None, targets=None, **tf_vars):
        "Runs Terraform plan and returns plan and module resources."
        plan = _plan_runner(
            fixture_path, tf_var_file=tf_var_file, targets=targets, **tf_vars
        )
        return plan, recursive_resources(plan.root_module)

    return run_plan
