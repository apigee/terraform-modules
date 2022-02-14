# Apigee X via IaC Automation Pipeline exposed in Multiple GCP Regions with Shared VPC and External HTTPS Load Balancer

## Setup Instructions

This sample deploys in a sligthly different manner than you might be used to in case you have explored the other samples in this repository. 

Deploying this sample happens in two stages.
1. As a first step the Terraform scripts in this directory will create a Bootstrap [GCP Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with all the resources required to deploy Apigee X with an Infrastructure as Code (IaC) Automation Pipeline).
2. The second step will leverage two [Cloud Source Repositories](https://cloud.google.com/source-repositories) and [Cloud Build](https://cloud.google.com/build) for deploying Apigee X with the surrounding resources as well as a simple httpbin Proxy.

Please refer to the below diagram for a graphical representation of the architecutre for this sample.

<p align="center">
  <img src="./sample-architecture.png?raw=true" alt="Apigee X Shared VPC Multi Region Sample Architecture">
</p>

Note that the sample uses an EVAL Apigee X Organization and hence a single Apigee X Instance only. In case you have a PROD Apigee X Organization then you will be able to easily extend the sample accordingly.

You can deploy this sample by executing the shell commands listed below.  

Set the project ID where you want your Apigee Organization to be deployed to:

```sh
PROJECT_ID=my-project-id
```

Draw a copy of the x-demo.tfvars to customize your Terraform Input Variables.

```sh
cp ./x-demo.tfvars ./my-config.tfvars
```
At a minimum you will have to overwrite the following variables:
* billing_account: Set this to your billing account identifier 
* project_parent: Set this to either 'organizations/0123456789' or 'folders/0123456789' where '0123456789' is either your GCP Organization identifier or the GCP Folder identifier respectively.

Decide on a [backend](https://www.terraform.io/docs/language/settings/backends/index.html) and create the necessary config. To use a backend on Google Cloud Storage (GCS) use:

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

and provision the Bootstrap GCP Project:

```sh
terraform apply --var-file=./my-config.tfvars -var "project_id=$PROJECT_ID"
```

Create the Infrastructure as Code (takes roughly 25min):

```sh
cd ./infra/
./00_setupRepo.sh $PROJECT_ID 
```
**Warning**: This step will kick off a Cloud Build in the Boostrap GCP Project.
* Check the Cloud Build history in your Bootstrap GCP Project on https://console.cloud.google.com/cloud-build/builds?supportedpurview=project and make sure the build completes before continuing to the next step.

Provision a simple httpbin Proxy:

```sh
cd ../app/
./00_setupRepo.sh $PROJECT_ID 
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app-tfstate-bucket"></a> [app-tfstate-bucket](#module\_app-tfstate-bucket) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs | v12.0.0 |
| <a name="module_bootstrap-project"></a> [bootstrap-project](#module\_bootstrap-project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v9.0.2 |
| <a name="module_infra-tfstate-bucket"></a> [infra-tfstate-bucket](#module\_infra-tfstate-bucket) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gcs | v12.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_billing_account_iam_member.billing_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_cloudbuild_trigger.app_trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_cloudbuild_trigger.infra_trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_folder_iam_member.folder_project_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_organization_iam_member.org_project_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.org_xpn_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.organization_folder_xpn_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_sourcerepo_repository.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |
| [google_sourcerepo_repository.infra](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |
| [google_folder.bootstrap_folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Build environment | `string` | `"poc"` | no |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Bootstrap Project Id (used to bootstrap the remaining resources). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the bootstrap resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
