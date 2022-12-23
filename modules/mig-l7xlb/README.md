# HTTPS Loadbalancer for Managed Instance Group Backend

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_service.mig_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_global_forwarding_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_health_check.mig_lb_hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_target_https_proxy.https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_migs"></a> [backend\_migs](#input\_backend\_migs) | List of MIGs to be used as backends. | `list(string)` | n/a | yes |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | (Optional) External IP for the L7 XLB. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of label key:value pairs to assign to the forwarding rule.<br>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | External LB name. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id. | `string` | n/a | yes |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | (Optional) The security policy associated with this backend service. | `string` | `null` | no |
| <a name="input_ssl_certificate"></a> [ssl\_certificate](#input\_ssl\_certificate) | SSL certificate for the HTTPS LB. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
