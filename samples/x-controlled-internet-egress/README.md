# Apigee X with Internet Traffic routed to a firewall appliance

In this example we are routing internet traffic to a mocked firewall appliance
(a VM with NATing via iptables) to illustrate how all internet egress traffic
can be centrally inspected before leaving the VPC.

To turn off direct internet egress traffic for the Apigee service network (by
forcing all egress traffic to go through the firewall appliance of this sample)
run the following command after you provisioned this sample:

```sh
gcloud services vpc-peerings enable-vpc-service-controls \
  --network=NETWORK --project=PROJECT_ID
```

## Setup Instructions

Please see the main [README](https://github.com/apigee/terraform-modules#deploying-end-to-end-samples)
for detailed instructions.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_mock-firewall"></a> [mock-firewall](#module\_mock-firewall) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm | v16.0.0 |
| <a name="module_nat"></a> [nat](#module\_nat) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat | v16.0.0 |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v16.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_glb_to_mig_bridge](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_route.egress_via_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.firewall_to_internet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_firewall_appliance_subnet"></a> [firewall\_appliance\_subnet](#input\_firewall\_appliance\_subnet) | Subnet for the mocked egress firewall appliance. | <pre>object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_firewall_appliance_tags"></a> [firewall\_appliance\_tags](#input\_firewall\_appliance\_tags) | Network Tags for the mocked egress firewall appliance. | `list(string)` | <pre>[<br>  "egress-fw"<br>]</pre> | no |
| <a name="input_firewall_appliance_zone"></a> [firewall\_appliance\_zone](#input\_firewall\_appliance\_zone) | GCP Compute Zone for the mocked egress firewall appliance. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC network to peer with the Apigee tennant project. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Service Peering CIDR range. | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
