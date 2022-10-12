terraform apply --var-file=./hybrid-demo.tfvars -var "project_id=strebel-hybrid-tf" -auto-approve

gcloud container clusters get-credentials hybrid-cluster --region europe-west1 --project strebel-hybrid-tf

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.3/cert-manager.yaml

# git clone https://github.com/danistrebel/apigee-hybrid-install.git && cd apigee-hybrid-install && git checkout gke-config
git clone https://github.com/apigee/apigee-hybrid-install.git && cd apigee-hybrid-install

./tools/apigee-hybrid-setup.sh --setup-all --verbose \
  --org strebel-hybrid-tf \
  --env test1 \
  --envgroup test \
  --ingress-domain test.apigee.example.com \
  --cluster-name hybrid-cluster \
  --cluster-region europe-west1 \
  --gcp-project-id  strebel-hybrid-tf

# todo fix workload id
# APIGEE_NAMESPACE=apigee

./tools/apigee-hybrid-setup.sh --fill-values --create-ingress-tls-certs --verbose \
  --org strebel-hybrid-tf \
  --env test1 \
  --envgroup test \
  --ingress-domain test.apigee.example.com \
  --cluster-name hybrid-cluster \
  --cluster-region europe-west1 \
  --gcp-project-id  strebel-hybrid-tf

INSTALL_DIR=$(pwd)
export DEFAULT_ENVIRONMENT_NAME=test
export ENVIRONMENT_NAME=test1

mv ${INSTALL_DIR}/overlays/instances/instance1/environments/${DEFAULT_ENVIRONMENT_NAME} ${INSTALL_DIR}/overlays/instances/instance1/environments/${ENVIRONMENT_NAME}

export DEFAULT_ENVGROUP_NAME=test-envgroup
export ENVGROUP_NAME=test

mv ${INSTALL_DIR}/overlays/instances/instance1/route-config/${DEFAULT_ENVGROUP_NAME} ${INSTALL_DIR}/overlays/instances/instance1/route-config/${ENVGROUP_NAME}


# ./tools/apigee-hybrid-setup.sh --setup-all --verbose \
#   --org strebel-hybrid-tf \
#   --env test1 \
#   --envgroup test \
#   --ingress-domain test.apigee.example.com \
#   --cluster-name hybrid-cluster \
#   --cluster-region europe-west1 \
#   --gcp-project-id  strebel-hybrid-tf


INSTALL_DIR=$(pwd)
# #TODO add await cert manager
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

kubectl apply -f ${INSTALL_DIR}/overlays/instances/instance1/datastore/secrets.yaml
kubectl apply -f ${INSTALL_DIR}/overlays/instances/instance1/redis/secrets.yaml
kubectl apply -f ${INSTALL_DIR}/overlays/instances/instance1/environments/${ENVIRONMENT_NAME}/secrets.yaml
kubectl apply -f ${INSTALL_DIR}/overlays/instances/instance1/organization/secrets.yaml

# # # TODO: fix paths
kubectl kustomize ${INSTALL_DIR}/overlays/instances/instance1 --reorder none | kubectl apply -f -

TOKEN=$(gcloud auth print-access-token)
curl -X POST -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type:application/json" \
  "https://apigee.googleapis.com/v1/organizations/strebel-hybrid-tf:setSyncAuthorization" \
   -d '{"identities":["'"serviceAccount:apigee-all-sa@strebel-hybrid-tf.iam.gserviceaccount.com"'"]}'