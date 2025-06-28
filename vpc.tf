#Creating the VPC resource
resource "google_compute_network" "main_vpc" {
  name                    = "vpc-${var.environment}"
  auto_create_subnetworks = false
}

#Start creating the subnetworks for dev enviroment here

resource "google_compute_subnetwork" "frontend-subnet" {
  name          = "frontend-subnet"
  ip_cidr_range = "10.0.10.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
}

resource "google_compute_subnetwork" "backend-subnet" {
  name          = "backend-subnet"
  ip_cidr_range = "10.0.20.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
}

# Reserve IP address range for Cloud SQL
resource "google_compute_global_address" "db_subnet_private_range" {
  name          = "db-subnet-range"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  address       = "10.0.30.0"
  prefix_length = 24
  network       = google_compute_network.main_vpc.id
}

# Create private connection for Cloud SQL
resource "google_service_networking_connection" "db_vpc_peering" {
  network                 = google_compute_network.main_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_subnet_private_range.name]
}

resource "google_compute_subnetwork" "vpn-cvpn-subnet" {
  name          = "cvpn-subnet"
  ip_cidr_range = "10.0.40.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
}

#Allow HTTP/HTTPS traffic in frontend subnet

resource "google_compute_firewall" "allow_http_htpps" {
  name    = "allow-http-traffic-frontend"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_backend_sql_communication" {
  name    = "allow-backend-sql-communication"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["10.0.20.0/24"]
}
