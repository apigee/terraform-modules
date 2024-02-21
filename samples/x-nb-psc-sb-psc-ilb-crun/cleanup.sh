#!/bin/sh
# Copyright 2023 Google LLC
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

set -e

SCRIPTPATH="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

# Ask for input parameters if they are not set

[ -z "$GCP_PROJECT_ID" ]     && printf "GCP project id: "    && read -r GCP_PROJECT_ID

###
### destroy_common_gcp_resources()
###
destroy_common_gcp_resources() {

  terraform init
  terraform destroy --var-file="./input.tfvars" \
    -var "gcp_project_id=${GCP_PROJECT_ID}"
    -auto-approve
}

## 
###
### destroy_common_gcp_resources()
###
main() {
  cd ${SCRIPTPATH}
  destroy_common_gcp_resources
}

main "${@}"
