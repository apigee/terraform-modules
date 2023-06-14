# Apigee X with an Internal L4 Load Balancer and Client Authentication (mTLS)

This sample provides a envoy-based managed instance group behind an internal
load balancer that can terminate mutual TLS (mTLS) to authenticate API clients.

## Preparation

This example assumes that you have TLS credentials for the server as well as
the clients available and set their path in the .tfvars file.

To try it out you can create a set of self signed certs:

```sh
mkdir ./certs && cd ./certs
openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout server-ca.key -x509 -days 3650 -outform PEM -out server-ca.crt -subj "/CN=Test Server CA"
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=test.api.example.com"
openssl x509 -req -in server.csr -CA server-ca.crt -CAkey server-ca.key -set_serial 100 -days 365 -outform PEM -out server.crt

openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout client-ca.key -x509 -days 3650 -outform PEM -out client-ca.crt -subj "/CN=Test Client CA"
openssl genrsa -out example-client.key 2048
openssl req -new -key example-client.key -out example-client.csr -subj "/CN=Test Client"
openssl x509 -req -in example-client.csr -CA client-ca.crt -CAkey client-ca.key -set_serial 101 -days 365 -outform PEM -out example-client.crt
cd ..
```

And reference them in your tf.vars

```tf
ca_cert_path  = "./certs/client-ca.crt"
tls_cert_path = "./certs/server.crt"
tls_key_path  = "./certs/server.key"
```

## Setup Instructions

Please see the main [README](https://github.com/apigee/terraform-modules#deploying-end-to-end-samples)
for detailed instructions.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee-x-core"></a> [apigee-x-core](#module\_apigee-x-core) | ../../modules/apigee-x-core | n/a |
| <a name="module_apigee-x-mtls-mig"></a> [apigee-x-mtls-mig](#module\_apigee-x-mtls-mig) | ../../modules/apigee-x-mtls-mig | n/a |
| <a name="module_ilb"></a> [ilb](#module\_ilb) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-ilb | v16.0.0 |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v16.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_ilb_hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    node_config = optional(object({<br>      min_node_count = optional(number)<br>      max_node_count = optional(number)<br>    }))<br>    iam       = optional(map(list(string)))<br>    envgroups = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_apigee_instances"></a> [apigee\_instances](#input\_apigee\_instances) | Apigee Instances (only one instance for EVAL orgs). | <pre>map(object({<br>    region       = string<br>    ip_range     = string<br>    environments = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_ca_cert_path"></a> [ca\_cert\_path](#input\_ca\_cert\_path) | Path to User CA Cert File (pem). | `string` | n/a | yes |
| <a name="input_exposure_subnets"></a> [exposure\_subnets](#input\_exposure\_subnets) | Subnets for exposing Apigee services. | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC name. | `string` | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | mTLS proxy network tags | `list(string)` | <pre>[<br>  "apigee-mtls-proxy"<br>]</pre> | no |
| <a name="input_peering_range"></a> [peering\_range](#input\_peering\_range) | Peering CIDR range | `string` | n/a | yes |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_support_range"></a> [support\_range](#input\_support\_range) | Support CIDR range of length /28 (required by Apigee for troubleshooting purposes). | `string` | n/a | yes |
| <a name="input_tls_cert_path"></a> [tls\_cert\_path](#input\_tls\_cert\_path) | Path to Server Cert File (pem). | `string` | n/a | yes |
| <a name="input_tls_key_path"></a> [tls\_key\_path](#input\_tls\_key\_path) | Path to Server Key File (pem). | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
