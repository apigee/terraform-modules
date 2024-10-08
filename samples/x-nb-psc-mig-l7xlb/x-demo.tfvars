/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

      
ax_region       = "europe-west1" 
billing_account = ""            
billing_type    = "EVAL"        
project_parent  = "organizations/406283053755"           
      
vpc_name        = "apigeexvpc"
peering_range   = "10.1.0.0/16"
support_range1  = "10.2.0.0/28"

lb_name         = "apigeexlb"
ssl_crt_domains = ["xyz.com"]



# Apigee configurations
apigee_envgroups = {
  "testgroup" = { hostnames = ["example.xyz.com"] }
  # Add more environment groups if needed
}

apigee_instances = {
  "euw1-instance" = {
    region       = "europe-west1"    
    ip_range     = "10.1.4.0/22"              
    environments = ["test"] 
  },

}

apigee_environments = {
  "test" = {
    display_name = "TEST" 
    description  = ""              
    iam          = null
    envgroups    = ["testgroup"] 

  }
  # Add more environments if needed
}


exposure_subnets = [
  {
    name               = "apigee-exposure-1"
    ip_cidr_range      = "10.100.0.0/24"
    region             = "europe-west1"
    instance           = "euw1-instance"
    secondary_ip_range = null
  },

]

psc_subnets = [
    {
    name               = "psc-subnet-1"
    ip_cidr_range      = "10.100.255.240/29"
    region             = "europe-west1"
    instance           = "euw1-instance"
    secondary_ip_range = null
  },

]

