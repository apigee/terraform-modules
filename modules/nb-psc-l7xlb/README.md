<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_service.psc_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_global_forwarding_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_target_https_proxy.https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | External IP for the L7 XLB. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of label key:value pairs to assign to the forwarding rule.<br>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | External LB name. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network for the PSC NEG | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id. | `string` | n/a | yes |
| <a name="input_psc_negs"></a> [psc\_negs](#input\_psc\_negs) | List of PSC NEGs to be used as backends. | `list(string)` | n/a | yes |
| <a name="input_psc_service_attachments"></a> [psc\_service\_attachments](#input\_psc\_service\_attachments) | Map of region to service attachment ID (currently only one map entry is allowed). | `map(string)` | `{}` | no |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | (Optional) The security policy associated with this backend service. | `string` | `null` | no |
| <a name="input_ssl_certificate"></a> [ssl\_certificate](#input\_ssl\_certificate) | SSL certificate for the HTTPS LB. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Subnetwork for the PSC NEG | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
