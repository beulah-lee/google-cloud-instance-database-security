terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  project = "database-security-445803"
  region  = "us-central1"
}

// VPC and Subnet
resource "google_compute_network" "default" {
  name = "db-security-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "db-security-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.name

  secondary_ip_range {
    range_name    = "db-security-range"
    ip_cidr_range = "10.1.0.0/24"
  }
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider          = google
  network           = google_compute_network.default.self_link
  service           = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_range.name]
}

resource "google_compute_global_address" "private_range" {
  name          = "private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.self_link
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["3306"] // MySQL port
  }

  source_ranges = ["10.0.0.0/24", "10.1.0.0/24"]
}

// Allow external MySQL traffic for my personal IP
resource "google_compute_firewall" "allow_external" {
  name    = "allow-external"
  network = google_compute_network.default.name
  priority = 0

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["108.91.40.74/32"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA" # Enables logging with full metadata
  }
}

// Deny all other external traffic for MySQL
resource "google_compute_firewall" "deny-external" {
  name    = "deny-external"
  network = google_compute_network.default.name
  priority = 1

  deny {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}

// MySQL Instance
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-instance"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  deletion_protection = true

  settings {
    tier              = "db-f1-micro"
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"
    disk_type         = "PD_HDD"
    disk_size         = 10

    ip_configuration {
      ipv4_enabled    = true 
      private_network = google_compute_network.default.self_link 
      require_ssl     = true

      authorized_networks {
        name  = "personal-ip"
        value = "108.91.40.74/32"
      }
    }

    backup_configuration {
      enabled    = true
      start_time = "01:00"
    }

    database_flags {
      name  = "audit_log"
      value = "ON"
    }
  }

  depends_on = [
    google_compute_network.default,
    google_service_networking_connection.private_vpc_connection,
    google_kms_crypto_key.db_security_key,
  ]
}

resource "google_sql_user" "root_user" {
  name     = "root"
  instance = google_sql_database_instance.mysql_instance.name
  host     = "%"
  password = "password"

  depends_on = [google_sql_database_instance.mysql_instance]
}

resource "google_sql_database_instance" "read_replica" {
  name             = "mysql-instance-replica"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  master_instance_name = google_sql_database_instance.mysql_instance.name

  settings {
    tier = "db-n1-standard-1"
  }
}

// Outputs for resource names
output "vpc_name" {
  value = google_compute_network.default.name
}

output "subnet_name" {
  value = google_compute_subnetwork.default.name
}

//CMEK for Backup Encryption
resource "google_kms_crypto_key" "db_security_key" {
  name     = "db-encryption-key"
  key_ring = google_kms_key_ring.db-security-key-ring.id
}

resource "google_kms_key_ring" "db-security-key-ring" {
  name     = "db-security-key-ring"
  location = "us-central1"
}

resource "google_project_iam_binding" "cloud_sql_kms_binding" {
  project = "database-security-445803"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:99137593349@cloudsql.gserviceaccount.com",
  ]
}

// IAM Roles and Service Accounts
resource "google_service_account" "db_service_account" {
  account_id   = "db-access-sa"
  display_name = "Service Account for Cloud SQL Access"
}

resource "google_project_iam_member" "sql_client" { 
  project = "database-security-445803"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.db_service_account.email}"
}

output "service_account_email" { 
  value = google_service_account.db_service_account.email
}

resource "google_project_iam_binding" "kms_access" {
  project = "database-security-445803"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:99137593349@your-project-id.iam.gserviceaccount.com",
  ]
}

// Client Certificates for Cloud SQL
resource "google_sql_ssl_cert" "client_cert" {
  instance    = google_sql_database_instance.mysql_instance.name
  common_name = "client"
}

// Outputs for the generated key and certificate
output "client_cert_private_key" {
  value     = google_sql_ssl_cert.client_cert.private_key
  sensitive = true
}

output "client_cert_cert" {
  value = google_sql_ssl_cert.client_cert.cert
}

