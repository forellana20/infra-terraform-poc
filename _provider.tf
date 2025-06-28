terraform {
  required_version = "~> 1.9.0" # Match it on .github/workflows tf_version parameter

  backend "gcs" {
    # The bucket comes from backends/{env}.config
    # Run terraform init -reconfigure -backend-config backends/{env}.config
    # to switch between environments
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.4.0"
    }
  }
}

# Provider using Application Default Credentials (for fetching the secret)
provider "google" {
  alias   = "secret_manager"
  project = var.project_id
  region  = var.region
}

# Fetch the service account key from Secret Manager using the previous provider
data "google_secret_manager_secret_version" "terraform_service_account_key" {
  provider = google.secret_manager
  secret   = "terraform-service-account-key"
  project  = var.project_id
}

# Main provider using the secret fetched from Secret Manager
# for impersonation of the "terraform" SA
provider "google" {
  credentials = data.google_secret_manager_secret_version.terraform_service_account_key.secret_data
  project     = var.project_id
  region      = var.region
}