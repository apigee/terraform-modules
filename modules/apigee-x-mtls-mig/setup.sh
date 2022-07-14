#!/bin/bash

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

mkdir -p /var/apigee/certs

BUCKET=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/BUCKET -H "Metadata-Flavor: Google")

gsutil cp "gs://$BUCKET/cacert.pem" /var/apigee/certs
gsutil cp "gs://$BUCKET/servercert.pem" /var/apigee/certs
gsutil cp "gs://$BUCKET/serverkey.pem" /var/apigee/certs
gsutil cp "gs://$BUCKET/envoy-config.yaml" /var/apigee/config.yaml

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

sudo docker run \
    -p 9901:9901 \
    -p 443:10000 \
    -v /var/apigee:/opt/apigee \
    envoyproxy/envoy:v1.18-latest -c /opt/apigee/config.yaml