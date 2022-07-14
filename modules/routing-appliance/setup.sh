#! /bin/bash

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

# Configure Health Check
mkdir /var/health-check
echo "OK" > /var/health-check/index.html
(cd  /var/health-check && python3 -m http.server 80 &)
echo "Configured Health Check on Port 80"

iptables -F
iptables -t nat -A POSTROUTING -j MASQUERADE
echo "Configured IP Table NAT"

echo 1 > /proc/sys/net/ipv4/ip_forward
echo "Enabled IP Forwarding"
