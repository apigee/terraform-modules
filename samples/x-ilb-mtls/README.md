# Apigee X with Internal L4 Load Balancer and Client Authentication (mTLS)

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_apigee-x-mtls-mig"></a> [apigee-x-mtls-mig](#module\_apigee-x-mtls-mig) | ../../modules/apigee-x-mtls-mig | n/a |
| <a name="module_ilb"></a> [ilb](#module\_ilb) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb | v6.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v6.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    environments = list(string)<br>    hostnames    = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environment Names. | `list(string)` | `[]` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one for EVAL). | <pre>map(object({<br>    region       = string<br>    cidr_mask    = number<br>    environments = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_ca_cert_path"></a> [ca\_cert\_path](#input\_ca\_cert\_path) | Path to User CA Cert File (pem). | `string` | n/a | yes |
| <a name="input_exposure_subnets"></a> [exposure\_subnets](#input\_exposure\_subnets) | Subnets for exposing Apigee services. | <pre>list(object({<br>    name          = string<br>    ip_cidr_range = string<br>    region        = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC name. | `string` | n/a | yes |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_tls_cert_path"></a> [tls\_cert\_path](#input\_tls\_cert\_path) | Path to Server Cert File (pem). | `string` | n/a | yes |
| <a name="input_tls_key_path"></a> [tls\_key\_path](#input\_tls\_key\_path) | Path to Server Key File (pem). | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->