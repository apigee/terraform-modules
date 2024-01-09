# Apigee X with Transitive Peering

Provisions a basic network appliance VM that allows accessing an Apigee X endpoint from a transitively peered VPC network.

Some background information and explanations can be found in [this community article](https://www.googlecloudcommunity.com/gc/Cloud-Product-Articles/Using-network-appliances-to-overcome-the-transitive-VPC-peering/ta-p/76070).

![](https://lh6.googleusercontent.com/28BZv53VXefXr9h6czW8deUqTSym5sFWgyGEwCm5QzcYjOOvcUKlr8N5zs6CRBYlQiHP63_r-wXOsvoM7M7MAYUsuAR0KCQuBgB8ZEDzxghoTt5oHP0BFKeBgzXad2DCx-ikxIezAjPxKWFvn2NzQ0cNBbcqgSIQ8Yk4OaDnRsVLzpKc)

This sample contains:
* Apigee Basic Setup with internal Endpoint
* Internal HTTP Backend MIG with ILB
* Network Appliance MIG with custom routes for backend and the Apigee IP range.
* Firewalls

To validate or demo the setup:
1. In a browser open the [Apigee UI](https://apigee.google.com)
1. Ensure you are in the correct Apigee Organization
1. Create an passthrough API proxy with base path `/internal` and a hostname of `http://BACKEND_ILB_IP`
1. Create and ssh into a temporary bastion VM in the backend network or use one of the backend VMs directly.
1. Set the `ENDPOINT_IP` variable to your internal Apigee Endpoint and call the API proxy with: `curl https://test.api.example.com/internal/get --resolve test.api.example.com:443:${ENDPOINT_IP} -kv`

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
| <a name="module_backend-example"></a> [backend-example](#module\_backend-example) | ../../modules/development-backend | n/a |
| <a name="module_backend-vpc"></a> [backend-vpc](#module\_backend-vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |
| <a name="module_peering-apigee-backend"></a> [peering-apigee-backend](#module\_peering-apigee-backend) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc-peering | v28.0.0 |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v28.0.0 |
| <a name="module_routing-appliance"></a> [routing-appliance](#module\_routing-appliance) | ../../modules/routing-appliance | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v28.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow-appliance-ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-backend-ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>    type      = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_network"></a> [apigee\_network](#input\_apigee\_network) | Apigee VPC name. | `string` | n/a | yes |
| <a name="input_appliance_forwarded_ranges"></a> [appliance\_forwarded\_ranges](#input\_appliance\_forwarded\_ranges) | CDIR ranges that should route via the network appliance | <pre>map(object({<br>    range    = string<br>    priority = number<br>  }))</pre> | `{}` | no |
| <a name="input_appliance_name"></a> [appliance\_name](#input\_appliance\_name) | Name for the routing appliance | `string` | `"routing-appliance"` | no |
| <a name="input_appliance_region"></a> [appliance\_region](#input\_appliance\_region) | GCP Region for Routing Appliance (ensure this matches appliance\_subnet.region). | `string` | n/a | yes |
| <a name="input_appliance_subnet"></a> [appliance\_subnet](#input\_appliance\_subnet) | Subnet to host the routing appliance | <pre>object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | Name for the Demo Backend | `string` | `"demo-backend"` | no |
| <a name="input_backend_network"></a> [backend\_network](#input\_backend\_network) | Peered Backend VPC name. | `string` | n/a | yes |
| <a name="input_backend_region"></a> [backend\_region](#input\_backend\_region) | GCP Region Backend (ensure this matches backend\_subnet.region). | `string` | n/a | yes |
| <a name="input_backend_subnet"></a> [backend\_subnet](#input\_backend\_subnet) | Subnet to host the backend service | <pre>object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
