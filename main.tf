#Storage account for document_hub
resource "google_storage_bucket" "hub_documentos" {
  name          = var.environment == "dev" ? "hub-documentos" : "hub-documentos-${var.environment}"
  location      = "US"
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

# Artifact Registry repository
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "docker-repo"
  description   = "Docker repository"
  format        = "DOCKER"
}
