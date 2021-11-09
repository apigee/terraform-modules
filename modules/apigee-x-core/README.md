# Apigee Core Setup

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee"></a> [apigee](#module\_apigee) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-organization | v8.0.0 |
| <a name="module_apigee-x-instance"></a> [apigee-x-instance](#module\_apigee-x-instance) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-x-instance | v8.0.0 |
| <a name="module_kms-inst-disk"></a> [kms-inst-disk](#module\_kms-inst-disk) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms | v8.0.0 |
| <a name="module_kms-org-db"></a> [kms-org-db](#module\_kms-org-db) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms | v8.0.0 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.apigee_sa](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    environments = list(string)<br>    hostnames    = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environment Names. | `list(string)` | `[]` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL). | <pre>map(object({<br>    region       = string<br>    cidr_mask    = number<br>    environments = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network (self-link) to peer with the Apigee tennant project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_endpoints"></a> [instance\_endpoints](#output\_instance\_endpoints) | Map of instance name -> internal runtime endpoint IP address |
<!-- END_TF_DOCS -->