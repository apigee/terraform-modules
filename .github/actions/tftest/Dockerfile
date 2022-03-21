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

FROM python:3-alpine

RUN apk add --no-cache \
    git

ENV TERRAFORM_VERSION=1.1.7

RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/bin/terraform

# Fake path for testing
COPY fake-key.json /var/fake-key.json
ENV GOOGLE_APPLICATION_CREDENTIALS="/var/fake-key.json"

COPY requirements.txt /var/requirements.txt
RUN pip3 install --no-cache-dir --no-warn-script-location -r /var/requirements.txt

ENTRYPOINT [ "python3", "-m", "pytest" ]