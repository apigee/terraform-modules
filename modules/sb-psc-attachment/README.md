<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.83, <6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_apigee_endpoint_attachment.endpoint_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_endpoint_attachment) | resource |
| [google_apigee_target_server.target_server](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_target_server) | resource |
| [google_compute_service_attachment.psc_service_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_organization"></a> [apigee\_organization](#input\_apigee\_organization) | Apigee organization where the Endpoint Attachment should be added to. Apigee Organization ID should be prefixed with 'organizations/' | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the service attachment. | `string` | n/a | yes |
| <a name="input_nat_subnets"></a> [nat\_subnets](#input\_nat\_subnets) | One or more NAT subnets to be used for PSC. | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region where the service attachment should be created. | `string` | n/a | yes |
| <a name="input_target_servers"></a> [target\_servers](#input\_target\_servers) | Map of target servers to be created and associated with the endpoint attachment. | <pre>map(object({<br>    environment_id = string<br>    name           = string<br>    protocol       = optional(string, "HTTP")<br>    port           = optional(number, 80)<br>    enabled        = optional(bool, true)<br>    s_sl_info = optional(object({<br>      enabled                  = bool<br>      client_auth_enabled      = optional(bool, null)<br>      key_store                = optional(string, null)<br>      key_alias                = optional(string, null)<br>      trust_store              = optional(string, null)<br>      ignore_validation_errors = optional(bool, null)<br>      protocols                = optional(list(string), null)<br>      ciphers                  = optional(list(string), null)<br>      common_name = optional(object({<br>        value          = optional(string, null)<br>        wildcard_match = optional(bool, null)<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_target_service"></a> [target\_service](#input\_target\_service) | Target Service for the service attachment e.g. a forwarding rule. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_attachment_connection_state"></a> [endpoint\_attachment\_connection\_state](#output\_endpoint\_attachment\_connection\_state) | Underlying connection state for the endpoint attachment. |
| <a name="output_endpoint_attachment_host"></a> [endpoint\_attachment\_host](#output\_endpoint\_attachment\_host) | Host for the endpoint attachment to be used in Apigee. |
<!-- END_TF_DOCS -->
