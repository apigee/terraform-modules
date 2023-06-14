
# Apigee Terraform Modules

This repository provides terraform modules and ready to use end-to-end examples for Apigee.

## Prerequisites

* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) cli on your PATH in version >= 1.1 (or according to the version constraint in the respective module).

## Modules

Currently the following modules are a available and can be used either as part of the end-to-end examples or as part of your own scripting:

* [Apigee X Core](modules/apigee-x-core) Configures a complete Apigee X organization with multiple instances, environment groups, and environments.
* [Apigee X Bridge MIG](modules/apigee-x-bridge-mig) Configures a managed instance group of network bridge GCE instances (VMs) that can be used as a load balancer backend and forward traffic to the internal Apigee X endpoint.
* [Apigee X mTLS MIG](modules/apigee-x-mtls-mig) Configures a managed instance group of Envoy proxies that can be used to terminate mutual TLS and forward traffic to the internal Apigee X endpoint.
* [L7 external LB for MIG](modules/mig-l7xlb) Configures an external HTTPS Cloud Load Balancer that fronts managed instance groups.
* [L4 external LB for MIG](modules/mig-l7xlb) Configures an external TCP Proxy that fronts managed instance groups.
* [Routing Appliance](modules/routing-appliance) Configures a routing appliance and custom routes to overcome transitive peering problems.
* [Northbound PSC Backend](modules/nb-psc-l7xlb) Private Service Connect (PSC) Network Endpoint Group (NEG) backend with an HTTPS external load balancer.
* [Southbound PSC Backend](modules/sb-psc-attachment) Private Service Connect (PSC) service attachment and Apigee endpoint attachment.
* [Development Backend](modules/development-backend) Configures an example HTTP backend and an internal load balancer.
* [NIP.io Development Hostname](modules/nip-development-hostname) Configures an external IP address and hostname based on the IP and the nip.io mechanism as well as a Google-managed SSL certificate.

## Deploying End-To-End Samples

Set the project ID where you want your Apigee Organization to be deployed to:

```sh
PROJECT_ID=my-project-id
```

Select one of the available sample deployments:

* [X Basic](samples/x-basic) for a basic Apigee X setup with the raw instance endpoints exposed as internal IP addresses.
* [X with external L7 LB](samples/x-l7xlb) for an Apigee X setup that is exposed via a global external L7 load balancer.
* [X with external L7 LB and northbound PSC](samples/x-nb-psc-xlb) for an Apigee X setup that uses a global external L7 load balancer and a Private Service Connect (PSC) Network Endpoint Group (NEG) to connect to an Apigee instance's service attachment.
* [X with southbound PSC](samples/x-sb-psc) for an Apigee X setup that uses Private Service Connect (PSC) to connect to a backend service in another VPC.
* [X with internal L4 LB and mTLS](samples/x-ilb-mtls) for a basic Apigee X setup plus exposure via regional L4 load balancer and envoy proxy to terminate mTLS.
* [X with external L4 LB and mTLS](samples/x-l4xlb-mtls) for a basic Apigee X setup plus exposure via global external L4 load balancer and envoy proxy to terminate mTLS.
* [X with network appliance for transitive peering](samples/x-transitive-peering) for an Apigee X organization that is peered to a network is transitively peered to another VPC that contains the backend.
To deploy the sample, first create a copy of the example variables and edit according to your requirements.
* [X with DNS peering](samples/x-dns-peering) for a basic Apigee X setup with DNS peering with a private DNS Zone containing records for Apigee and an example backend.
* [X with controlled internet egress](samples/x-controlled-internet-egress) for a basic Apigee X setup with the runtime's internet egress routed via a firewall appliance in the customer's VPC.
* [X with Shared VPC](samples/x-shared-vpc) for an Apigee X setup in a Shared VPC that is exposed via a global external L7 load balancer.
* [X with Multi Region](samples/x-multi-region) for an Apigee X setup in a Shared VPC exposed in multiple GCP Regions via a global L7 load balancer. Note that the sample uses an EVAL Apigee X Organization and hence a single Apigee X Instance only. In case you have a PROD Apigee X Organization then you will be able to easily extend the sample accordingly.
* [X with IaC Automation Pipeline](samples/x-iac-pipeline) for an IaC Automation Pipeline Apigee X setup in a Shared VPC exposed in multiple GCP Regions via a global L7 load balancer. Note that the sample uses an EVAL Apigee X Organization and hence a single Apigee X Instance only. In case you have a PROD Apigee X Organization then you will be able to easily extend the sample accordingly.

```sh
cd samples/... # Sample from above
cp ./x-demo.tfvars ./my-config.tfvars
```

Decide on a [backend](https://www.terraform.io/language/settings/backends) and create the necessary config. To use a backend on Google Cloud Storage (GCS) use:

```sh
gsutil mb "gs://$PROJECT_ID-tf"

cat <<EOF >terraform.tf
terraform {
  backend "gcs" {
    bucket  = "$PROJECT_ID-tf"
    prefix  = "terraform/state"
  }
}
EOF
```

Validate your config:

```sh
terraform init
terraform plan --var-file=./my-config.tfvars -var "project_id=$PROJECT_ID"
```

and provision everything (takes roughly 25min):

```sh
terraform apply --var-file=./my-config.tfvars -var "project_id=$PROJECT_ID"
```

## Known issues

* Currently, there are no known issues specific to this module.
* Feel free to [create an issue](https://github.com/apigee/terraform-modules/issues/new)
  if you came across anything.
* Please also see the list of [open issues](https://github.com/hashicorp/terraform-provider-google/issues?q=is%3Aissue+is%3Aopen+apigee)
  in the upstream terraform provider that could be inherited by this module.

## License

All solutions within this repository are provided under the
[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license.
Please see the [LICENSE](/LICENSE) file for more detailed terms and conditions.

## Disclaimer

This repository and its contents are not an official Google product.
