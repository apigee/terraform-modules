
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
  source              = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-organization?ref=v16.0.0"
  project_id          = module.project.project_id
  analytics_region    = var.ax_region
  runtime_type        = "HYBRID"
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
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
  node_machine_type  = "e2-standard-4"
  initial_node_count = 1
  node_tags          = ["apigee-hybrid", "apigee-runtime"]
}

module "gke-nodepool-data" {
  source             = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-nodepool?ref=v16.0.0"
  project_id         = module.project.project_id
  cluster_name       = module.gke-cluster.name
  location           = module.gke-cluster.location
  name               = "apigee-data"
  node_machine_type  = "e2-standard-4"
  initial_node_count = 1
  node_tags          = ["apigee-hybrid", "apigee-data"]
}

resource "google_sourcerepo_repository" "apigee-override" {
  project = module.project.project_id
  name    = "apigee-override"
}

resource "google_sourcerepo_repository" "apigee-k8s" {
  project = module.project.project_id
  name    = "apigee-k8s-resources"
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

module "nat" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=v16.0.0"
  project_id     = module.project.project_id
  region         = var.gke_cluster.region
  name           = "nat-${var.gke_cluster.region}"
  router_network = module.vpc.self_link
}

module "apigee-service-account" {
  source             = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v16.0.0"
  project_id         = module.project.project_id
  name               = "apigee-all-sa"
  iam       = {
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
    "${module.project.project_id}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/storage.objectAdmin",
      "roles/apigee.analyticsAgent",
      "roles/apigee.synchronizerManager",
      "roles/apigeeconnect.Agent",
      "roles/apigee.runtimeAgent"
    ]
  }
}