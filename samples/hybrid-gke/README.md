# Apigee hybrid installation

This example shows how to use Terraform to create a GKE cluster to run Apigee hybrid and how to feed the configuration parameters in to the new [installation tooling](https://github.com/apigee/apigee-hybrid-install) that is currently in preview.

## Installing the control plane and infrastructure components to run Apigee hybrid

```sh
terraform apply --var-file=./hybrid-demo.tfvars -var "project_id=$PROJECT_ID"
```

## Configuring Apigee hybrid

### Fetch the configuration parameters from the terraform state

```sh
CLUSTER_REGION="$(terraform output -raw cluster_region)"
CLUSTER_NAME="$(terraform output -raw cluster_name)"
ENV_GROUPS=$(terraform output -json apigee_envgroups)
ENV_GROUP_NAME=$(echo $ENV_GROUPS | jq -r "to_entries[0].key")
ENV_NAME=$(echo $ENV_GROUPS | jq -r "to_entries[0].value.environments[0]")
INGRESS_DOMAIN=$(echo $ENV_GROUPS | jq -r "to_entries[0].value.hostnames[0]")
```

### Log into the cluster

```
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_REGION" --project "$PROJECT_ID"
```

### Prepare the Workload Configuration

```sh
git clone https://github.com/apigee/apigee-hybrid-install.git
cd apigee-hybrid-install

./tools/apigee-hybrid-setup.sh --configure-directory-names --fill-values --create-gcp-sa-and-secrets --create-ingress-tls-certs --verbose \
  --org "$PROJECT_ID" \
  --env "$ENV_NAME" \
  --envgroup "$ENV_GROUP_NAME" \
  --ingress-domain "$INGRESS_DOMAIN" \
  --cluster-name "$CLUSTER_NAME" \
  --cluster-region "$CLUSTER_REGION" \
  --gcp-project-id "$PROJECT_ID"
```

and enable the sychonrizer for accessing the control plane

```sh
TOKEN=$(gcloud auth print-access-token)

curl -X POST -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type:application/json" \
  "https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}:setSyncAuthorization" \
   -d "{\"identities\":[\"serviceAccount:apigee-all-sa@${PROJECT_ID}.iam.gserviceaccount.com\"]}"
```

### Seal the secrets (Optional but recommended for GitOps)

By default the sealed secrets operator is installed as part of the terraform module.
It allows you to create Kubernetes secrets as encrypted secrets that can only be decrypted by the Kubernetes master.

If you wish to hold on to the unencrypted secrets or manage your secrets using another mechanism you can skip this section.

Prerequisites admin workstation:

* [kubeseal](https://github.com/bitnami-labs/sealed-secrets#overview)

```sh
seal_secret () {
  secret_file_name="$1"
  echo "Sealing Secret in: $secret_file_name"
  plain_file_name="$(dirname $secret_file_name)/plain.$(basename $secret_file_name)"
  echo "Plain Secret is still available in $plain_file_name"
  mv "$secret_file_name" "$plain_file_name"

  if grep -q -- '---' "$plain_file_name"; then
    parent_dir=$(dirname $plain_file_name)
    tmp_split_dir='./tmp-splits'
    mkdir -p "$tmp_split_dir"
    awk 'BEGIN {SR=1} /^-+$/{SR++} !/^-+$/{out="./tmp-splits/secret-"SR ".yaml"; print > out}' $plain_file_name
    for split_file in $tmp_split_dir/secret-*.yaml; do
        cat $split_file | kubeseal -o yaml >> "$secret_file_name"
        echo '---' >> "$secret_file_name"
    done
    rm -rf "$tmp_split_dir"
  else
    kubeseal -o yaml <"$plain_file_name" > "$secret_file_name"
  fi
}

INSTALL_DIR=$(pwd)
for INSTANCE_DIR in ${INSTALL_DIR}/overlays/instances/*; do
  seal_secret "${INSTANCE_DIR}/datastore/secrets.yaml"
  seal_secret "${INSTANCE_DIR}/redis/secrets.yaml"
  for ENV_DIR in ${INSTANCE_DIR}/environments/*/; do
    seal_secret "${ENV_DIR}secrets.yaml"
  done
  seal_secret "${INSTANCE_DIR}/organization/secrets.yaml"
done
```

Check the sealed secrets and remove the plain text

```
find . -type f -name 'plain.secrets.yaml' -delete
```


## Apply the k8s resources on the cluster

### Option 1 Cloudbuild

```sh
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
    --role="roles/container.admin"

cd .. # go to samples/hybrid-gke folder
gcloud builds submit --substitutions="_CLUSTER_NAME=$CLUSTER_NAME,_CLUSTER_REGION=$CLUSTER_REGION,_INGRESS_DOMAIN=$INGRESS_DOMAIN" --project $PROJECT_ID
```

### Option 2 Apply one by one

```sh
INSTALL_DIR=$(pwd)
kubectl apply -f ${INSTALL_DIR}/overlays/initialization/namespace.yaml
kubectl apply -k ${INSTALL_DIR}/overlays/initialization/certificates
kubectl apply --server-side --force-conflicts -k ${INSTALL_DIR}/overlays/initialization/crds
kubectl apply -k ${INSTALL_DIR}/overlays/initialization/webhooks
kubectl apply -k ${INSTALL_DIR}/overlays/initialization/rbac
kubectl apply -k ${INSTALL_DIR}/overlays/initialization/ingress
# Create controller config and controller
kubectl apply -k ${INSTALL_DIR}/overlays/controllers

# # Wait for the controllers to be available
kubectl wait deployment/apigee-controller-manager deployment/apigee-ingressgateway-manager -n apigee --for=condition=available --timeout=2m

for INSTANCE_DIR in ${INSTALL_DIR}/overlays/instances/*; do
  kubectl apply -f ${INSTANCE_DIR}/datastore/secrets.yaml
  kubectl apply -f ${INSTANCE_DIR}/redis/secrets.yaml
  for ENV_DIR in ${INSTANCE_DIR}/environments/*/; do
    kubectl apply -f ${ENV_DIR}secrets.yaml
  done
  kubectl apply -f ${INSTANCE_DIR}/organization/secrets.yaml

  kubectl kustomize ${INSTANCE_DIR} --reorder none | kubectl apply -f -
done
```

### Verify all pods are up and running

```sh
kubectl get pod -n apigee
```

### Test the ingress route

```sh
INGRESS_IP=$(kubectl get service -n apigee -l app=apigee-ingressgateway --output jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
curl -kv --resolve $INGRESS_DOMAIN:443:$INGRESS_IP "https://$INGRESS_DOMAIN/my-proxy"
```


### Next Steps

* Use workload identity (through the kustomize components)
* Use nodepool annotations (through the kustomize components)
* Implement CD for TF and k8s resources

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigee"></a> [apigee](#module\_apigee) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee | v19.0.0 |
| <a name="module_apigee-service-account"></a> [apigee-service-account](#module\_apigee-service-account) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account | v16.0.0 |
| <a name="module_gke-cluster"></a> [gke-cluster](#module\_gke-cluster) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-cluster | v16.0.0 |
| <a name="module_gke-nodepool-data"></a> [gke-nodepool-data](#module\_gke-nodepool-data) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-nodepool | v16.0.0 |
| <a name="module_gke-nodepool-runtime"></a> [gke-nodepool-runtime](#module\_gke-nodepool-runtime) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-nodepool | v16.0.0 |
| <a name="module_nat"></a> [nat](#module\_nat) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat | v16.0.0 |
| <a name="module_project"></a> [project](#module\_project) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project | v16.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc | v16.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow-master-kubeseal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-master-webhook](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_sourcerepo_repository.apigee-k8s](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.sealed-secrets](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [google_client_config.provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_envgroups"></a> [apigee\_envgroups](#input\_apigee\_envgroups) | Apigee Environment Groups. | <pre>map(object({<br>    hostnames = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_apigee_environments"></a> [apigee\_environments](#input\_apigee\_environments) | Apigee Environments. | <pre>map(object({<br>    display_name = optional(string)<br>    description  = optional(string)<br>    iam          = optional(map(list(string)))<br>    envgroups    = list(string)<br>  }))</pre> | `null` | no |
| <a name="input_ax_region"></a> [ax\_region](#input\_ax\_region) | GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli). | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | Region/Zone for where to create the cluster. | `string` | n/a | yes |
| <a name="input_cluster_region"></a> [cluster\_region](#input\_cluster\_region) | Region for where to create the cluster. | `string` | n/a | yes |
| <a name="input_deploy_sealed_secrets"></a> [deploy\_sealed\_secrets](#input\_deploy\_sealed\_secrets) | Deploy the sealed-secrets operator (see https://github.com/bitnami-labs/sealed-secrets). | `bool` | `true` | no |
| <a name="input_gke_cluster"></a> [gke\_cluster](#input\_gke\_cluster) | GKE Cluster Specification | <pre>object({<br>    name                     = string<br>    region                   = string<br>    location                 = string<br>    master_ip_cidr           = string<br>    master_authorized_ranges = map(string)<br>    secondary_range_pods     = string<br>    secondary_range_services = string<br>  })</pre> | <pre>{<br>  "location": "europe-west1",<br>  "master_authorized_ranges": {<br>    "internet": "0.0.0.0/0"<br>  },<br>  "master_ip_cidr": "192.168.0.0/28",<br>  "name": "hybrid-cluster",<br>  "region": "europe-west1",<br>  "secondary_range_pods": "pods",<br>  "secondary_range_services": "services"<br>}</pre> | no |
| <a name="input_network"></a> [network](#input\_network) | Network name to be used for hosting the Apigee hybrid cluster. | `string` | `"apigee-network"` | no |
| <a name="input_node_locations_data"></a> [node\_locations\_data](#input\_node\_locations\_data) | List of locations for the data node pool | `list(string)` | `null` | no |
| <a name="input_node_machine_type_data"></a> [node\_machine\_type\_data](#input\_node\_machine\_type\_data) | Machine type for data node pool | `string` | `"e2-standard-4"` | no |
| <a name="input_node_machine_type_runtime"></a> [node\_machine\_type\_runtime](#input\_node\_machine\_type\_runtime) | Machine type for runtime node pool | `string` | `"e2-standard-4"` | no |
| <a name="input_node_preemptible_runtime"></a> [node\_preemptible\_runtime](#input\_node\_preemptible\_runtime) | Use preemptible VMs for runtime node pool | `bool` | `null` | no |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id (also used for the Apigee Organization). | `string` | n/a | yes |
| <a name="input_project_parent"></a> [project\_parent](#input\_project\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to be greated in the network. | <pre>list(object({<br>    name               = string<br>    ip_cidr_range      = string<br>    region             = string<br>    secondary_ip_range = map(string)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigee_envgroups"></a> [apigee\_envgroups](#output\_apigee\_envgroups) | Apigee Env Groups. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name. |
| <a name="output_cluster_region"></a> [cluster\_region](#output\_cluster\_region) | Cluster location. |

## Copyright

Copyright 2023 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
<!-- END_TF_DOCS -->
