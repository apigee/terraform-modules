/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  envgroups = { for key, value in var.apigee_envgroups : key => value.hostnames }
}

data "google_client_config" "provider" {}

provider "helm" {
  kubernetes {
    host  = "https://${module.gke-cluster.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      module.gke-cluster.ca_certificate,
    )
  }
}

module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v16.0.0"
  name            = var.project_id
  parent          = var.project_parent
  billing_account = var.billing_account
  project_create  = var.project_create
  services = [
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
    "sourcerepo.googleapis.com",
  ]
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v16.0.0"
  project_id = module.project.project_id
  name       = var.network
  subnets    = var.subnets
}

module "apigee" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee?ref=v19.0.0"
  project_id = module.project.project_id
  organization = {
    runtime_type     = "HYBRID"
    analytics_region = var.ax_region
  }
  envgroups    = local.envgroups
  environments = var.apigee_environments
}

module "gke-cluster" {
  source                   = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-cluster?ref=v16.0.0"
  project_id               = module.project.project_id
  name                     = var.gke_cluster.name
  location                 = var.gke_cluster.location
  network                  = module.vpc.self_link
  subnetwork               = module.vpc.subnet_self_links["${var.gke_cluster.region}/hybrid-${var.gke_cluster.region}"]
  secondary_range_pods     = "pods"
  secondary_range_services = "services"
  master_authorized_ranges = var.gke_cluster.master_authorized_ranges
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.gke_cluster.master_ip_cidr
    master_global_access    = true
  }
}

module "gke-nodepool-runtime" {
  source             = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-nodepool?ref=v16.0.0"
  project_id         = module.project.project_id
  cluster_name       = module.gke-cluster.name
  location           = module.gke-cluster.location
  name               = "apigee-runtime"
  node_machine_type  = var.node_machine_type_runtime
  node_preemptible   = var.node_preemptible_runtime
  initial_node_count = 1
  node_tags          = ["apigee-hybrid", "apigee-runtime"]
}

module "gke-nodepool-data" {
  source             = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-nodepool?ref=v16.0.0"
  project_id         = module.project.project_id
  cluster_name       = module.gke-cluster.name
  location           = module.gke-cluster.location
  name               = "apigee-data"
  node_machine_type  = var.node_machine_type_data
  initial_node_count = 1
  node_tags          = ["apigee-hybrid", "apigee-data"]
  node_locations     = var.node_locations_data
}

resource "google_sourcerepo_repository" "apigee-k8s" {
  project = module.project.project_id
  name    = "apigee-config"
}

resource "google_compute_firewall" "allow-master-webhook" {
  project   = module.project.project_id
  name      = "gke-master-apigee-webhooks"
  network   = module.vpc.self_link
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["9443"]
  }
  target_tags = ["apigee-hybrid"]
  source_ranges = [
    var.gke_cluster.master_ip_cidr,
  ]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.7.3"

  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    module.gke-cluster
  ]

}

resource "helm_release" "sealed-secrets" {
  count      = var.deploy_sealed_secrets ? 1 : 0
  name       = "sealed-secrets-controller"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.7.0"
  namespace  = "kube-system"

  depends_on = [
    module.gke-cluster
  ]

}

resource "google_compute_firewall" "allow-master-kubeseal" {
  count     = var.deploy_sealed_secrets ? 1 : 0
  project   = module.project.project_id
  name      = "gke-master-kubeseal"
  network   = module.vpc.self_link
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  target_tags = ["apigee-hybrid"]
  source_ranges = [
    var.gke_cluster.master_ip_cidr,
  ]
}

module "nat" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=v16.0.0"
  project_id     = module.project.project_id
  region         = var.gke_cluster.region
  name           = "nat-${var.gke_cluster.region}"
  router_network = module.vpc.self_link
}

module "apigee-service-account" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v16.0.0"
  project_id = module.project.project_id
  name       = "apigee-all-sa"
  iam = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-cassandra-schema-setup-svc-account-${module.project.project_id}]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-cassandra-user-setup-svc-account-${module.project.project_id}]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-connect-agent-svc-account-${module.project.project_id}]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-datastore-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-mart-svc-account-${module.project.project_id}]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-metrics-adapter-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-metrics-app-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-metrics-proxy-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-redis-default-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-redis-envoy-default-svc-account]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-runtime-svc-account-${module.project.project_id}-test1]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-synchronizer-svc-account-${module.project.project_id}-test1]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-udca-svc-account-${module.project.project_id}-test1]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-udca-svc-account-${module.project.project_id}]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[apigee/apigee-watcher-svc-account-${module.project.project_id}]",
    ]
  }
  iam_project_roles = {
    "module.project.project_id" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/storage.objectAdmin",
      "roles/apigee.analyticsAgent",
      "roles/apigee.synchronizerManager",
      "roles/apigeeconnect.Agent",
      "roles/apigee.runtimeAgent"
    ]
  }
  depends_on = [
    module.gke-cluster
  ]
}
