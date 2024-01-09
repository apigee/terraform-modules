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

template_string="$(cat .github/actions/update-docs/sample-instructions.template.md)"
export template_string


# create a copy to compare docs updates
workdir=$PWD
original_content_clone=$PWD/../docs-clone
(cd .. && cp -r "$workdir" "$original_content_clone")

# run terraform docs
for TYPE in samples modules; do
  for D in "$TYPE"/*; do
    # set the generic sample instructions if required
    perl -i.bkp -0pe 's|<!-- BEGIN_SAMPLES_DEFAULT_SETUP_INSTRUCTIONS.+?END_SAMPLES_DEFAULT_SETUP_INSTRUCTIONS -->|$ENV{template_string}|gs;' "$D/README.md"
    rm "$D/README.md.bkp"

    # run terraform docs
    terraform-docs --lockfile=false --hide header --hide requirements markdown table --output-file README.md --output-mode inject "$D"
  done
done

changes=$(git diff --name-only --no-index -- "$original_content_clone" "$workdir" | grep 'README.md$' || true )

if [ -z "$changes" ];then
  echo "Docs Are up to date 🎉"
elif [ "$FAIL_ON_OUTDATED" = "true" ]; then
  echo "The Documentation in the following README files is out of date:"
  echo "$changes"
  git diff
  echo "Please run the docs generator workflow manually and commit your changes:"
  echo "./tools/update-docs.sh"
  exit 1
else
  echo "Updated documentation for the following README files:"
  echo "$changes"
  echo "Make sure you commit them to this branch before you create your PR."
fi