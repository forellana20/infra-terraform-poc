resource "random_id" "postgres_db_suffix" {
  byte_length = 2
}

resource "google_sql_database_instance" "postgres_sql" {
  name   = "postgres-sql-${random_id.postgres_db_suffix.hex}"
  region = var.region

  deletion_protection = true

  database_version = "POSTGRES_15"

  settings {
    tier                        = var.postgres_db_tier
    availability_type           = var.postgres_db_availability_type
    edition                     = var.postgres_db_edition
    deletion_protection_enabled = true
    disk_type                   = "PD_SSD"

    ip_configuration {
      # Don't enable authorized_networks, use Cloud SQL Auth Proxy instead
      ipv4_enabled       = true
      private_network    = google_compute_network.vpc.id
      allocated_ip_range = google_compute_global_address.db_subnet_private_range.name
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    insights_config {
      query_insights_enabled = true
    }

    backup_configuration {
      enabled = true

      start_time = "10:00" # Time in UTC
      location   = "us"

      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = 8
      }
    }

    maintenance_window {
      # Time in UTC
      day          = 7
      hour         = 4
      update_track = "stable"
    }
  }

  depends_on = [google_service_networking_connection.db_vpc_peering]
}

resource "google_sql_database" "document_hub_db" {
  name     = "DocumentHub"
  instance = google_sql_database_instance.postgres_sql.name
}

resource "google_sql_database" "user_accounts_db" {
  name     = "user_accounts"
  instance = google_sql_database_instance.postgres_sql.name
}

# Google Groups are managed outside of Terraform. They were created
# as an end user due to the permissions for the service account at the 
# organization level.
# See: https://cloud.google.com/identity/docs/how-to/setup#auth-no-dwd
#
# IAM Groups:
# sql-dba
# sql-dev
# sql-audit
#
# IAM Service accounts:
# sql-app-access

# Groups
resource "google_sql_user" "postgres_dba" {
  name     = "sql-dba@${var.org_domain}"
  instance = google_sql_database_instance.postgres_sql.name
  type     = "CLOUD_IAM_GROUP"
}

resource "google_sql_user" "postgres_dev" {
  name     = "sql-dev@${var.org_domain}"
  instance = google_sql_database_instance.postgres_sql.name
  type     = "CLOUD_IAM_GROUP"
}

resource "google_sql_user" "postgres_audit" {
  name     = "sql-audit@${var.org_domain}"
  instance = google_sql_database_instance.postgres_sql.name
  type     = "CLOUD_IAM_GROUP"
}

# Service account
resource "google_service_account" "postgres_app_access" {
  account_id   = "sql-app-access"
  display_name = "SQL App Access"
  description  = "Service account to connect the application to Cloud SQL"
}

resource "google_sql_user" "postgres_app_access" {
  name     = trimsuffix(google_service_account.postgres_app_access.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.postgres_sql.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_user" "pts_identity_app" {
  name     = trimsuffix(google_service_account.cloudrun_pts_identity.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.postgres_sql.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
# Built_in admin
resource "random_password" "postgres_admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "postgres_admin_password" {
  secret_id = "postgres-admin-password"
  replication {
    auto {
      # Automatic replication
    }
  }
}

resource "google_secret_manager_secret_version" "postgres_admin_password" {
  secret = google_secret_manager_secret.postgres_admin_password.id

  secret_data = random_password.postgres_admin_password.result
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.postgres_admin_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
  ]
}

resource "google_sql_user" "postgres_admin" {
  name     = "sql-admin"
  password = random_password.postgres_admin_password.result
  instance = google_sql_database_instance.postgres_sql.name
  type     = "BUILT_IN"
}

# Cloud SQL roles

## Needed for Cloud SQL Auth Proxy to connect to Cloud SQL
resource "google_project_iam_binding" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "group:sql-dba@${var.org_domain}",
    "group:sql-dev@${var.org_domain}",
    "group:sql-audit@${var.org_domain}",
    google_service_account.postgres_app_access.member
  ]
}

## Needed for IAM authentication in Cloud SQL
resource "google_project_iam_binding" "sql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"

  members = [
    "group:sql-dba@${var.org_domain}",
    "group:sql-dev@${var.org_domain}",
    "group:sql-audit@${var.org_domain}",
    google_service_account.postgres_app_access.member
  ]
}

resource "random_password" "pts_identity_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "pts_identity_password" {
  secret_id = "pts-identity-password"
  replication {
    auto {
      # Automatic replication
    }
  }
}

resource "google_secret_manager_secret_version" "pts_identity_password" {
  secret = google_secret_manager_secret.pts_identity_password.id

  secret_data = random_password.pts_identity_password.result
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_binding" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.pts_identity_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_identity.member
  ]
}

resource "google_sql_user" "pts_identity" {
  name     = "pts-identity"
  password = random_password.pts_identity_password.result
  instance = google_sql_database_instance.postgres_sql.name
  type     = "BUILT_IN"
}

resource "random_password" "pts_process_engine_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "pts_process_engine_password" {
  secret_id = "pts-process-engine-password"
  replication {
    auto {
      # Automatic replication
    }
  }
}

resource "google_secret_manager_secret_version" "pts_process_engine_password" {
  secret = google_secret_manager_secret.pts_process_engine_password.id

  secret_data = random_password.pts_process_engine_password.result
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_binding" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.pts_process_engine_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_process_engine.member
  ]
}

resource "google_sql_user" "pts_process_engine" {
  name     = "pts-process-engine"
  password = random_password.pts_process_engine_password.result
  instance = google_sql_database_instance.postgres_sql.name
  type     = "BUILT_IN"
}