<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_demo-backend-mig"></a> [demo-backend-mig](#module\_demo-backend-mig) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig | v16.0.0 |
| <a name="module_demo-backend-template"></a> [demo-backend-template](#module\_demo-backend-template) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm | v16.0.0 |
| <a name="module_ilb-backend"></a> [ilb-backend](#module\_ilb-backend) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.hc-allow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCE Machine type. | `string` | `"e2-small"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Example Backend. | `string` | `"demo-backend"` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network for running the MIGs (needs to be peered with the Apigee tenant project). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region for the MIGs. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | VPC subnet for running the MIGs | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ilb_forwarding_rule_address"></a> [ilb\_forwarding\_rule\_address](#output\_ilb\_forwarding\_rule\_address) | ILB forwarding rule IP address. |
| <a name="output_ilb_forwarding_rule_self_link"></a> [ilb\_forwarding\_rule\_self\_link](#output\_ilb\_forwarding\_rule\_self\_link) | ILB forwarding rule self link. |
| <a name="output_instance_group"></a> [instance\_group](#output\_instance\_group) | Backend Service MIG. |
<!-- END_TF_DOCS -->