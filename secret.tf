# AWS Code Artifact
resource "google_secret_manager_secret" "aws_code_artifact_credentials" {
  secret_id = "aws-code-artifact-credentials"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "aws_code_artifact_iam" {
  secret_id = google_secret_manager_secret.aws_code_artifact_credentials.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    google_service_account.cloudbuild.member
  ]
}

# Cloud SQL

# pts-identity - DBHOST
resource "google_secret_manager_secret" "pts_identity_db_host" {
  secret_id = "pts-identity-db-host"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_identity_db_host" {
  secret = google_secret_manager_secret.pts_identity_db_host.id

  secret_data = google_sql_database_instance.postgres_sql.private_ip_address
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_db_host_accessor" {
  secret_id = google_secret_manager_secret.pts_identity_db_host.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_identity.member
  ]
}

# pts-identity - DBNAME
resource "google_secret_manager_secret" "pts_identity_db_name" {
  secret_id = "pts-identity-db-name"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_identity_db_name" {
  secret = google_secret_manager_secret.pts_identity_db_name.id

  secret_data = google_sql_database.user_accounts_db.name
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_db_name_accessor" {
  secret_id = google_secret_manager_secret.pts_identity_db_name.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_identity.member
  ]
}

# pts-identity - DBUSER
resource "google_secret_manager_secret" "pts_identity_db_user" {
  secret_id = "pts-identity-db-user"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_identity_db_user" {
  secret = google_secret_manager_secret.pts_identity_db_user.id

  secret_data = google_sql_user.pts_identity.name
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_db_user_accessor" {
  secret_id = google_secret_manager_secret.pts_identity_db_user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_identity.member
  ]
}

# pts-identity - DBPASSWORD
resource "google_secret_manager_secret" "pts_identity_db_password" {
  secret_id = "pts-identity-db-password"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_identity_db_password" {
  secret = google_secret_manager_secret.pts_identity_db_password.id

  secret_data = google_sql_user.pts_identity.password
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_db_password_accessor" {
  secret_id = google_secret_manager_secret.pts_identity_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_identity.member
  ]
}

# pts-identity - JWT_SECRET
resource "google_secret_manager_secret" "pts_identity_jwt_secret" {
  secret_id = "pts-identity-jwt-secret"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "pts_identity_jwt_accessor" {
  secret_id = google_secret_manager_secret.pts_identity_jwt_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    google_service_account.cloudrun_pts_identity.member
  ]
}

# pts-process-engine - DBHOST
resource "google_secret_manager_secret" "pts_process_engine_db_host" {
  secret_id = "pts-process-engine-db-host"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_process_engine_db_host" {
  secret = google_secret_manager_secret.pts_process_engine_db_host.id

  secret_data = google_sql_database_instance.postgres_sql.private_ip_address
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_db_host_accessor" {
  secret_id = google_secret_manager_secret.pts_process_engine_db_host.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_process_engine.member
  ]
}

# pts-process-engine - DBNAME
resource "google_secret_manager_secret" "pts_process_engine_db_name" {
  secret_id = "pts-process-engine-db-name"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_process_engine_db_name" {
  secret = google_secret_manager_secret.pts_process_engine_db_name.id

  secret_data = google_sql_database.gestion_tributaria_db.name
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_db_name_accessor" {
  secret_id = google_secret_manager_secret.pts_process_engine_db_name.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_process_engine.member
  ]
}

# pts-process-engine - DBUSER
resource "google_secret_manager_secret" "pts_process_engine_db_user" {
  secret_id = "pts-process-engine-db-user"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_process_engine_db_user" {
  secret = google_secret_manager_secret.pts_process_engine_db_user.id

  secret_data = google_sql_user.pts_process_engine.name
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_db_user_accessor" {
  secret_id = google_secret_manager_secret.pts_process_engine_db_user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_process_engine.member
  ]
}

# pts-process-engine - DBPASSWORD
resource "google_secret_manager_secret" "pts_process_engine_db_password" {
  secret_id = "pts-process-engine-db-password"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pts_process_engine_db_password" {
  secret = google_secret_manager_secret.pts_process_engine_db_password.id

  secret_data = google_sql_user.pts_process_engine.password
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_db_password_accessor" {
  secret_id = google_secret_manager_secret.pts_process_engine_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "group:sql-dba@${var.org_domain}",
    google_service_account.cloudrun_pts_process_engine.member
  ]
}

# pts-process-engine - JWT_SECRET
resource "google_secret_manager_secret" "pts_process_engine_jwt_secret" {
  secret_id = "pts-process-engine-jwt-secret"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "pts_process_engine_jwt_secret_accessor" {
  secret_id = google_secret_manager_secret.pts_process_engine_jwt_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    google_service_account.cloudrun_pts_process_engine.member
  ]
}
