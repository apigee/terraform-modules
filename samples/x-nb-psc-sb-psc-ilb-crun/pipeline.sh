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

[ -z "$GCP_PROJECT_ID" ] && printf "GCP project id: "    && read -r GCP_PROJECT_ID
[ -z "$APIGEE_X_ORG" ] && printf "Apigee X Organization: "    && read -r APIGEE_X_ORG
[ -z "$APIGEE_X_ENV" ] && printf "Apigee X Environment: "    && read -r APIGEE_X_ENV
[ -z "$APIGEE_X_HOSTNAME" ] && printf "Apigee X Hostname: "    && read -r APIGEE_X_HOSTNAME

###
### create_common_gcp_resources()
###
create_common_gcp_resources() {

  terraform init

  terraform plan -var "gcp_project_id=${GCP_PROJECT_ID}" \
      --var-file=./input.tfvars

  terraform apply -var "gcp_project_id=${GCP_PROJECT_ID}" \
      --var-file=./input.tfvars \
      -auto-approve
}

## 
###
### create_common_gcp_resources()
###
main() {
  cd "$SCRIPTPATH"
  create_common_gcp_resources
  # Cloud Run app url
  APP_URL=$(terraform output -json service_urls | jq -r '.[0]')
  
  # dynamic set of the audience
  CLOUDRUN_APP_SUFFIX=$(echo "${APP_URL}" | sed "s/https:\/\/login//")
  export CLOUDRUN_APP_SUFFIX
  envsubst < "$SCRIPTPATH"/templates/AM-SetAudience.template.xml > "$SCRIPTPATH"/cloudrun-api-v1/apiproxy/policies/AM-SetAudience.xml

  # deploy the Apigee api proxy
  APIGEE_TOKEN="$(gcloud config config-helper --force-auth-refresh --format json | jq -r '.credential.access_token')"
  SA_EMAIL="apigee-apiproxy@$GCP_PROJECT_ID.iam.gserviceaccount.com"
  sackmesser deploy --googleapi \
    -o "$APIGEE_X_ORG" \
    -e "$APIGEE_X_ENV" \
    -t "$APIGEE_TOKEN" \
    -h "$APIGEE_X_HOSTNAME" \
    -d "$SCRIPTPATH"/cloudrun-api-v1 \
    --deployment-sa "$SA_EMAIL"
}

main "${@}"
