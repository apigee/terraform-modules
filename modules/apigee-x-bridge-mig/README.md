# Apigee Network Bridge Managed Instance Group

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bridge-mig"></a> [bridge-mig](#module\_bridge-mig) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig | v16.0.0 |
| <a name="module_bridge-template"></a> [bridge-template](#module\_bridge-template) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_glb_to_mig_bridge](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoint_ip"></a> [endpoint\_ip](#input\_endpoint\_ip) | Apigee X Instance Endpoint IP. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCE Machine type. | `string` | `"e2-small"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the bridge VMs/MIG (using apigee-$REGION as a fallback). | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network for running the MIGs (needs to be peered with the Apigee tenant project). | `string` | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags for the Bridge VMs. | `list(string)` | <pre>[<br>  "apigee-bridge"<br>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region for the MIGs. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | VPC subnet for running the MIGs | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_group"></a> [instance\_group](#output\_instance\_group) | Proxy MIGs for mTLS termination |
<!-- END_TF_DOCS -->