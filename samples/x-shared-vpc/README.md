# Apigee X in Shared VPC with External HTTPS Load Balancer

Apigee X installation in a shared VPC setup and with a an external HTTPS load balancer to route traffic via forwarding MIGs.

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

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-bridge-mig"></a> [apigee-x-bridge-mig](#module\_apigee-x-bridge-mig) | ../../modules/apigee-x-bridge-mig | n/a |
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_host-project"></a> [host-project](#module\_host-project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_mig-l7xlb"></a> [mig-l7xlb](#module\_mig-l7xlb) | ../../modules/mig-l7xlb | n/a |
| <a name="module_nip-development-hostname"></a> [nip-development-hostname](#module\_nip-development-hostname) | ../../modules/nip-development-hostname | n/a |
| <a name="module_service-project"></a> [service-project](#module\_service-project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_shared-vpc"></a> [shared-vpc](#module\_shared-vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>    type      = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_exposure_subnets"></a> [exposure\_subnets](#input\_exposure\_subnets) | Subnets for exposing Apigee services | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC name. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |
| <a name="input_svpc_host_project_id"></a> [svpc\_host\_project\_id](#input\_svpc\_host\_project\_id) | Shared VPC Host Project id). | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
