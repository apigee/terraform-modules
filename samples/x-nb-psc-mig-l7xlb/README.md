# Apigee X exposed in Multiple GCP Regions with PSC and MIG External HTTPS Load Balancer

End-to-end sample terraform code to provision Apigee X exposed by External Load Balancer with PSC and MIG.

If you plan to use LB-->PSC-NEG for Apigee northbound network routing, follow the instructions in this document to configure active health check. 
At this time, PSC-NEG does not support active health check monitoring as mentioned [here](https://cloud.google.com/load-balancing/docs/negs#psc-neg). 
To work around this limitation of PSC, you can modify the Apigee installation configuration to use a managed instance group (MIG), which does provide active health check capability. Refer the solution guide [here](https://cloud.google.com/apigee/docs/api-platform/system-administration/health-check-mig-workaround) and the network diagram below :

<p align="center">
  <img src="./sample-architecture.png?raw=true" alt="Apigee X Shared VPC Multi Region Sample Architecture">
</p>



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
| <a name="module_apigee-x-bridge-mig"></a> [apigee-x-bridge-mig](#module\_apigee-x-bridge-mig) | ../../modules/apigee-x-bridge-mig | n/a |
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_mig-l7xlb"></a> [mig-l7xlb](#module\_mig-l7xlb) | ../../modules/mig-l7xlb | n/a |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.psc_endpoint_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.psc_ilb_consumer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.external_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_managed_ssl_certificate.google_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_address.int_psc_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |
| [google_compute_global_address.my_lb_external_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_global_address) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>    type      = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data. | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account ID. | `string` | n/a | yes |
| <a name="input_billing_type"></a> [billing\_type](#input\_billing\_type) | Billing type of the Apigee organization. | `string` | `null` | no |
| <a name="input_exposure_subnets"></a> [exposure\_subnets](#input\_exposure\_subnets) | Subnets for exposing Apigee services | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    instance           = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_lb_name"></a> [lb\_name](#input\_lb\_name) | Name of the load balancer. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | n/a | yes |
| <a name="input_project_services"></a> [project\_services](#input\_project\_services) | List of services to enable in the project. | `list(string)` | <pre>[<br>  "apigee.googleapis.com",<br>  "cloudkms.googleapis.com",<br>  "compute.googleapis.com",<br>  "servicenetworking.googleapis.com"<br>]</pre> | no |
| <a name="input_psc_subnets"></a> [psc\_subnets](#input\_psc\_subnets) | Subnets for psc endpoints | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    instance           = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_ssl_crt_domains"></a> [ssl\_crt\_domains](#input\_ssl\_crt\_domains) | Domains for the managed SSL certificate. | `list(string)` | n/a | yes |
| <a name="input_support_range1"></a> [support\_range1](#input\_support\_range1) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Project ID. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
