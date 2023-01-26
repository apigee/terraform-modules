#!/bin/sh

# Copyright 2023 Google LLC.
# This software is provided as-is, without warranty or representation for any use or purpose.
# Your use of it is subject to your agreement with Google.

PROJECT_ID=$1
git init
git checkout -b poc
git add .
git commit -m 'Initial commit'
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google https://source.developers.google.com/p/"${PROJECT_ID}"/r/app-repo
git push --all google
