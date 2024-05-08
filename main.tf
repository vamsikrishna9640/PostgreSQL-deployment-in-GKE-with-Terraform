# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

# Create a VPC subnet
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "gke-subnet"
  region        = var.region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = var.ip_cidr_range

}

# Create a GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name               = "my-gke-cluster"
  location           = var.region
  initial_node_count = 1
  network            = google_compute_network.vpc_network.self_link
  subnetwork         = google_compute_subnetwork.vpc_subnet.self_link
  remove_default_node_pool = true
  
  # Configure node pool
  
}

resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.gke_cluster.name
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  
  node_count = var.node_count
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = var.machine_type
    
  }
}