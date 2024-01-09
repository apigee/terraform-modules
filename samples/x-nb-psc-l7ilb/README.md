# Apigee X with PSC and an internal HTTPS load balancer

This module will create an Apigee X instance that is fronted with an internal HTTPS load balancer and connected via PSC.

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

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_nb-psc-l7ilb"></a> [nb-psc-l7ilb](#module\_nb-psc-l7ilb) | ../../modules/nb-psc-l7ilb | n/a |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_psc-ingress-vpc"></a> [psc-ingress-vpc](#module\_psc-ingress-vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_region_network_endpoint_group.psc_neg](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>    type      = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances_metadata"></a> [apigee\_instances\_metadata](#input\_apigee\_instances\_metadata) | Metadata for Apigee Instances (only one instance for EVAL orgs) along with L7 ILB configuration. | <pre>map(object({<br>    apigee_instances = object({<br>      region       = string<br>      ip_range     = string<br>      environments = list(string)<br>    })<br>    l7_ilb_proxy_subnet_name       = string<br>    l7_ilb_proxy_subnet_cidr_range = string<br>    l7_ilb_name_prefix             = string<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC name. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_psc_ingress_network"></a> [psc\_ingress\_network](#input\_psc\_ingress\_network) | PSC ingress VPC name. | `string` | n/a | yes |
| <a name="input_psc_ingress_subnets"></a> [psc\_ingress\_subnets](#input\_psc\_ingress\_subnets) | Subnets for exposing Apigee services via PSC. | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
