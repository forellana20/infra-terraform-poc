variable "environment" {
  type = string
}

# General
variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "Preferred GCP region"
  type        = string
}

variable "zone" {
  description = "Preferred GCP zone"
  type        = string
}

variable "org_domain" {
  description = "Organization domain"
  type        = string
}

# Cloud SQL

variable "postgres_db_tier" {
  description = "Machine tier for the database instance"
  type        = string
}

variable "postgres_db_availability_type" {
  description = "Availability type for database instance"
  type        = string
}

variable "postgres_db_edition" {
  description = "Edition for database instance"
  type        = string
}
