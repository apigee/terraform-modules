# Apigee X via IaC Automation Pipeline exposed in Multiple GCP Regions with Shared VPC and External HTTPS Load Balancer

## Setup Instructions

Please see the main [README](https://github.com/apigee/terraform-modules#deploying-end-to-end-samples)
for detailed instructions.

<p align="center">
  <img src="./sample-architecture.png?raw=true" alt="Apigee X Shared VPC Multi Region Sample Architecture">
</p>

Note that the sample uses an EVAL Apigee X Organization and hence a single Apigee X Instance only. In case you have a PROD Apigee X Organization then you will be able to easily extend the sample accordingly.

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
| [google_folder_iam_member.folder_xpn_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_organization_iam_member.org_project_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.org_xpn_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_sourcerepo_repository.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |
| [google_sourcerepo_repository.infra](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |

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
