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

import pprint

def assert_envgroup_attachment(resources, envs):
    "Test Apigee Envgroup Attachments."
    attachments = resources_by_type(resources, "google_apigee_envgroup_attachment")
    assert len(attachments) == len(envs)
    for a in attachments:
        pprint.pprint(a)
    assert set(a["values"]["environment"] for a in attachments) == set(envs)


def assert_envgroup_name(resources, name, index=0):
    "Test env group."
    envgroups = resources_by_type(resources, "google_apigee_envgroup")
    assert len(envgroups) >= index+1
    assert envgroups[index]["values"]["name"] == name

def assert_envgroup_hostnames(resources, hostnames, index=0):
    "Test env group hostnames."
    envgroups = resources_by_type(resources, "google_apigee_envgroup")
    assert len(envgroups) >= index+1
    assert set(envgroups[index]["values"]["hostnames"]) == set(hostnames)

def assert_instance(resources, location, ip_range, index=0):
    "Test Apigee Instance Resource"
    instances = resources_by_type(resources, "google_apigee_instance")
    assert len(instances) >= index+1
    assert instances[index]["values"]["location"] == location
    assert instances[index]["values"]["ip_range"] == ip_range


def assert_instance_attachment(resources, attachment_ids):
    "Test Apigee Instance Attachments."
    attachments = resources_by_type(resources, "google_apigee_instance_attachment")
    assert len(attachments) == len(attachment_ids)
    attachment_ids_found = set(a["index"] for a in attachments)
    print(attachment_ids_found)
    assert set(attachment_ids_found) == set(attachment_ids)

def resources_by_type(resources, resourceType):
    "Filter resources by type."
    return [r for r in resources if r["type"] == resourceType ]

def resource_by_address(resources, address):
    "Finds resource by address and fails if address is not unique or does not exist."
    matched = [r for r in resources if r["address"] == address ]
    assert len(matched) == 1
    return matched[0]