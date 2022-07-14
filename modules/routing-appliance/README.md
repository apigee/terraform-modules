<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_appliance-sa"></a> [appliance-sa](#module\_appliance-sa) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account | v16.0.0 |
| <a name="module_config-bucket"></a> [config-bucket](#module\_config-bucket) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs | v16.0.0 |
| <a name="module_ilb-appliance"></a> [ilb-appliance](#module\_ilb-appliance) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb | v16.0.0 |
| <a name="module_routing-appliance-mig"></a> [routing-appliance-mig](#module\_routing-appliance-mig) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig | v16.0.0 |
| <a name="module_routing-appliance-template"></a> [routing-appliance-template](#module\_routing-appliance-template) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.hc-allow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_route.appliance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_storage_bucket_object.setup_script](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_id.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_forwarded_ranges"></a> [forwarded\_ranges](#input\_forwarded\_ranges) | CDIR ranges that should route via appliance | <pre>map(object({<br>    range    = string<br>    priority = number<br>  }))</pre> | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCE Machine type. | `string` | `"e2-small"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use for the routing appliance. | `string` | `"routing-appliance"` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network for running the routing appliance MIGs. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region for the MIGs. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | VPC subnet for running the MIGs | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_group"></a> [instance\_group](#output\_instance\_group) | Routing Appliance MIG |
<!-- END_TF_DOCS -->