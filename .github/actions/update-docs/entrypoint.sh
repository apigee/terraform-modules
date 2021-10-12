#!/bin/sh
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


set -e

for TYPE in samples modules; do
  for D in "$TYPE"/*; do
    terraform-docs --hide header --hide requirements markdown table --output-file README.md --output-mode inject "$D"
  done
done

changes=$(git diff --name-only | grep 'README.md$' || true )

if [ -z "$changes" ];then
  echo "Docs Are up to date 🎉"
elif [ "$FAIL_ON_OUTDATED" = "true" ]; then
  echo "The Documentation in the following README files is out of date:"
  echo "$changes"
  echo "Please run the docs generator workflow manually and commit your changes:"
  echo "./tools/update-docs.sh"
  exit -1
else
  echo "Updated documentation for the following README files:"
  echo "$changes"
  echo "Make sure you commit them to this branch before you create your PR."
fi