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
| [google_compute_forwarding_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_region_backend_service.psc_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy) | resource |
| [google_compute_region_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map) | resource |
| [google_compute_subnetwork.proxy_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_l7_ilb_name_prefix"></a> [l7\_ilb\_name\_prefix](#input\_l7\_ilb\_name\_prefix) | Prefix for the Load Balancer resources. | `string` | n/a | yes |
| <a name="input_l7_ilb_proxy_subnet_cidr_range"></a> [l7\_ilb\_proxy\_subnet\_cidr\_range](#input\_l7\_ilb\_proxy\_subnet\_cidr\_range) | IP CIDR Range for the L7 ILB Proxy-only Subnet. | `string` | n/a | yes |
| <a name="input_l7_ilb_proxy_subnet_name"></a> [l7\_ilb\_proxy\_subnet\_name](#input\_l7\_ilb\_proxy\_subnet\_name) | Name of the L7 ILB Proxy-only Subnet. | `string` | `"l7ilb-proxy-subnet"` | no |
| <a name="input_l7_ilb_subnet_id"></a> [l7\_ilb\_subnet\_id](#input\_l7\_ilb\_subnet\_id) | Subnet in which the Forwarding Rule should be created. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of label key:value pairs to assign to the forwarding rule.<br>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the GCP Project. | `string` | n/a | yes |
| <a name="input_psc_neg"></a> [psc\_neg](#input\_psc\_neg) | PSC NEG to be used as backend. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region in which the resources should be created. | `string` | n/a | yes |
| <a name="input_vpc_network_name"></a> [vpc\_network\_name](#input\_vpc\_network\_name) | Name of the VPC Network. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
