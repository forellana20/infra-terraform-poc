# Cloud Run
# pts-ui
resource "google_service_account" "cloudrun_pts_ui" {
  account_id   = "cr-pts-ui"
  display_name = "Cloud Run - pts-ui"
  description  = "Service account for Cloud Run service pts-ui"
}

#Cloud Run
# pts-identity
resource "google_service_account" "cloudrun_pts_identity" {
  account_id   = "cr-pts-identity"
  display_name = "Cloud Run - pts-identity"
  description  = "Service account for Cloud Run service pts-identity"
}

# pts-process-engine
resource "google_service_account" "cloudrun_pts_process_engine" {
  account_id   = "cr-pts-process-engine"
  display_name = "Cloud Run - pts-process-engine"
  description  = "Service account for Cloud Run service pts-process-engine"
}

# Cloud Build
resource "google_service_account" "cloudbuild" {
  account_id   = "cloudbuild"
  display_name = "Cloudbuild SA"
  description  = "Service account for Cloudbuild"
}

resource "google_project_iam_member" "logging_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.cloudbuild.member
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.cloudbuild.member
}

# Cloud Run permissions for cloudbuild
resource "google_project_iam_member" "cloudrun_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = google_service_account.cloudbuild.member
}

# Cloud Build SA <----> Cloud Run SA
resource "google_service_account_iam_member" "pts-ui-sa" {
  service_account_id = google_service_account.cloudrun_pts_ui.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.cloudbuild.member
}

resource "google_service_account_iam_member" "pts-identity-sa" {
  service_account_id = google_service_account.cloudrun_pts_identity.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.cloudbuild.member
}

resource "google_service_account_iam_member" "pts_process_engine_sa" {
  service_account_id = google_service_account.cloudrun_pts_process_engine.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.cloudbuild.member
}
