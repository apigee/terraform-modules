# Managed Instance Group with Client Authentication (mTLS)

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-mtls-proxy-mig"></a> [apigee-mtls-proxy-mig](#module\_apigee-mtls-proxy-mig) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-mig | v16.0.0 |
| <a name="module_apigee-mtls-proxy-template"></a> [apigee-mtls-proxy-template](#module\_apigee-mtls-proxy-template) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/compute-vm | v16.0.0 |
| <a name="module_config-bucket"></a> [config-bucket](#module\_config-bucket) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs | v16.0.0 |
| <a name="module_mtls-proxy-sa"></a> [mtls-proxy-sa](#module\_mtls-proxy-sa) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account | v16.0.0 |
| <a name="module_nat"></a> [nat](#module\_nat) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket_object.ca_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.envoy_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.setup_script](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.tls_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.tls_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_id.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_config"></a> [autoscaler\_config](#input\_autoscaler\_config) | Optional autoscaler configuration. Only one of 'cpu\_utilization\_target' 'load\_balancing\_utilization\_target' or 'metric' can be not null. | <pre>object({<br>    max_replicas                      = number<br>    min_replicas                      = number<br>    cooldown_period                   = number<br>    cpu_utilization_target            = number<br>    load_balancing_utilization_target = number<br>    metric = object({<br>      name                       = string<br>      single_instance_assignment = number<br>      target                     = number<br>      type                       = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE<br>      filter                     = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_ca_cert_path"></a> [ca\_cert\_path](#input\_ca\_cert\_path) | local CA Cert File Path for Client Authenication. | `string` | n/a | yes |
| <a name="input_endpoint_ip"></a> [endpoint\_ip](#input\_endpoint\_ip) | Apigee X Instance Endpoint IP. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCE Machine type. | `string` | `"e2-small"` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network for running the MIGs (needs to be peered with the Apigee tenant project). | `string` | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | network tags for the mTLS mig | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region for the MIGs. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | VPC subnet for running the MIGs | `string` | n/a | yes |
| <a name="input_target_size"></a> [target\_size](#input\_target\_size) | Group target size, leave null when using an autoscaler. | `number` | `2` | no |
| <a name="input_tls_cert_path"></a> [tls\_cert\_path](#input\_tls\_cert\_path) | local TLS Cert File Path for Client Authenication. | `string` | n/a | yes |
| <a name="input_tls_key_path"></a> [tls\_key\_path](#input\_tls\_key\_path) | local TLS Cert File Path for Client Authenication. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_group"></a> [instance\_group](#output\_instance\_group) | Proxy MIGs for mTLS termination |
<!-- END_TF_DOCS -->