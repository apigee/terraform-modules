# Apigee Core Setup

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee"></a> [apigee](#module\_apigee) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee | v28.0.0 |
| <a name="module_kms-inst-disk"></a> [kms-inst-disk](#module\_kms-inst-disk) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms | v28.0.0 |
| <a name="module_kms-org-db"></a> [kms-org-db](#module\_kms-org-db) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms | v28.0.0 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.apigee_sa](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string, "Terraform-managed")<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    type      = optional(string)<br>    envgroups = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL). | <pre>map(object({<br>    region               = string<br>    ip_range             = string<br>    environments         = list(string)<br>    keyring_create       = optional(bool, true)<br>    keyring_name         = optional(string, null)<br>    keyring_location     = optional(string, null)<br>    key_name             = optional(string, "inst-disk")<br>    key_rotation_period  = optional(string, "2592000s")<br>    key_labels           = optional(map(string), null)<br>    consumer_accept_list = optional(list(string), null)<br>  }))</pre> | `{}` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_type"></a> [billing\_type](#input\_billing\_type) | Billing type of the Apigee organization. | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Network (self-link) to peer with the Apigee tennant project. | `string` | n/a | yes |
| <a name="input_org_description"></a> [org\_description](#input\_org\_description) | Apigee org description | `string` | `"Apigee org created in TF"` | no |
| <a name="input_org_display_name"></a> [org\_display\_name](#input\_org\_display\_name) | Apigee org display name | `string` | `null` | no |
| <a name="input_org_key_rotation_period"></a> [org\_key\_rotation\_period](#input\_org\_key\_rotation\_period) | Rotaton period for the organization DB encryption key | `string` | `"2592000s"` | no |
| <a name="input_org_kms_keyring_create"></a> [org\_kms\_keyring\_create](#input\_org\_kms\_keyring\_create) | Set to false to manage the keyring for the Apigee Organization DB and IAM bindings in an existing keyring. | `bool` | `true` | no |
| <a name="input_org_kms_keyring_location"></a> [org\_kms\_keyring\_location](#input\_org\_kms\_keyring\_location) | Location of the KMS Key Ring for Apigee Organization DB. Matches AX region if not provided. | `string` | `null` | no |
| <a name="input_org_kms_keyring_name"></a> [org\_kms\_keyring\_name](#input\_org\_kms\_keyring\_name) | Name of the KMS Key Ring for Apigee Organization DB. | `string` | `"apigee-x-org"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_envgroups"></a> [envgroups](#output\_envgroups) | Apigee Environment Groups |
| <a name="output_environments"></a> [environments](#output\_environments) | Apigee Environments |
| <a name="output_instance_endpoints"></a> [instance\_endpoints](#output\_instance\_endpoints) | Map of instance name -> internal runtime endpoint IP address |
| <a name="output_instance_map"></a> [instance\_map](#output\_instance\_map) | Map of instance region -> instance object |
| <a name="output_instance_service_attachments"></a> [instance\_service\_attachments](#output\_instance\_service\_attachments) | Map of instance region -> instance PSC service attachment |
| <a name="output_org_id"></a> [org\_id](#output\_org\_id) | Apigee Organization ID in the format of 'organizations/<org\_id>' |
| <a name="output_organization"></a> [organization](#output\_organization) | Apigee Organization. |
<!-- END_TF_DOCS -->
