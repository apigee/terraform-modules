# Basic Apigee X Setup with internal backend reached through PSC

This module provides a southbound private service connect (PSC) connectivity between an
Apigee X runtime and a sample backend that is running on a standalone VPC.

<!-- BEGIN_SAMPLES_DEFAULT_SETUP_INSTRUCTIONS -->
## Setup Instructions

Set the project ID where you want your Apigee Organization to be deployed to:

```sh
PROJECT_ID=my-project-id
```

```sh
cd samples/... # Sample from above
cp ./x-demo.tfvars ./my-config.tfvars
```

Decide on a [backend](https://www.terraform.io/language/settings/backends) and create the necessary config. To use a backend on Google Cloud Storage (GCS) use:

```sh
gsutil mb "gs://$PROJECT_ID-tf"

cat <<EOF >terraform.tf
terraform {
  backend "gcs" {
    bucket  = "$PROJECT_ID-tf"
    prefix  = "terraform/state"
  }
}
EOF
```

Validate your config:

```sh
terraform init
terraform plan --var-file=./my-config.tfvars -var "project_id=$PROJECT_ID"
```

and provision everything (takes roughly 25min):

```sh
terraform apply --var-file=./my-config.tfvars -var "project_id=$PROJECT_ID"
```
<!-- END_SAMPLES_DEFAULT_SETUP_INSTRUCTIONS -->

## Validate the setup

A successful run will print the endpoint attachment's host that you can then
use for your target server in Apigee:

```txt
Outputs:

psc_endpoint_attachment_host = "7.0.5.2"
psc_endpoint_attachment_connection_state = "ACCEPTED"
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_backend-example"></a> [backend-example](#module\_backend-example) | ../../modules/development-backend | n/a |
| <a name="module_backend-vpc"></a> [backend-vpc](#module\_backend-vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_southbound-psc"></a> [southbound-psc](#module\_southbound-psc) | ../../modules/sb-psc-attachment | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_psc_nat_to_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_subnetwork.psc_nat_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>    type      = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (sxee https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | Name for the Demo Backend | `string` | `"demo-backend"` | no |
| <a name="input_backend_network"></a> [backend\_network](#input\_backend\_network) | Peered Backend VPC name. | `string` | n/a | yes |
| <a name="input_backend_psc_nat_subnet"></a> [backend\_psc\_nat\_subnet](#input\_backend\_psc\_nat\_subnet) | Subnet to host the PSC NAT. | <pre>object({<br>    name          = string<br>    ip_cidr_range = string<br>  })</pre> | n/a | yes |
| <a name="input_backend_region"></a> [backend\_region](#input\_backend\_region) | GCP Region Backend (ensure this matches backend\_subnet.region). | `string` | n/a | yes |
| <a name="input_backend_subnet"></a> [backend\_subnet](#input\_backend\_subnet) | Subnet to host the backend service. | <pre>object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC network to peer with the Apigee tennant project. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Service Peering CIDR range. | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_psc_name"></a> [psc\_name](#input\_psc\_name) | PSC name. | `string` | n/a | yes |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_psc_endpoint_attachment_connection_state"></a> [psc\_endpoint\_attachment\_connection\_state](#output\_psc\_endpoint\_attachment\_connection\_state) | Underlying connection state of the PSC endpoint attachment. |
| <a name="output_psc_endpoint_attachment_host"></a> [psc\_endpoint\_attachment\_host](#output\_psc\_endpoint\_attachment\_host) | Hostname of the PSC endpoint attachment. |
<!-- END_TF_DOCS -->
