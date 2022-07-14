
module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v15.0.0"
  name            = var.project_id
  parent          = var.project_parent
  billing_account = var.billing_account
  project_create  = var.project_create
  services = [
    "pubsub.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v15.0.0"
  project_id = module.project.project_id
  name       = var.network
  subnets    = var.subnets
}


module "apigee" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee-organization?ref=v15.0.0"
  project_id              = module.project.project_id
  analytics_region        = var.ax_region
  runtime_type            = "HYBRID"
  apigee_environments     = var.apigee_environments
  apigee_envgroups        = var.apigee_envgroups
}

module "gke-cluster" {
  source                    = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/gke-cluster?ref=v15.0.0"
  project_id                = module.project.project_id
  name                      = ar.gke_cluster.name
  location                  = var.gke_cluster.location
  network                   = module.vpc.self_link
  subnetwork                = module.vpc.subnet_self_links["${var.gke_cluster.region}/hybrid-${var.gke_cluster.region}"]
  secondary_range_pods      = var.gke_cluster.secondary_range_pods
  secondary_range_services  = var.gke_cluster.secondary_range_services
  default_max_pods_per_node = 32
  master_authorized_ranges = var.gke_cluster.master_authorized_ranges
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.gke_cluster.master_ip_cidr
    master_global_access    = true
  }
}