variable "project_id" {
  description = "GCP project ID for the dev environment."
  type        = string
}

variable "app_name" {
  description = "Application name used for resource labels."
  type        = string
  default     = "throughball"
}

variable "environment" {
  description = "Environment name. This foundation implements dev only."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "Only the dev environment is implemented by this Terraform foundation."
  }
}

variable "region" {
  description = "Single allowed GCP region for low-cost deployment."
  type        = string
  default     = "us-central1"

  validation {
    condition     = var.region == "us-central1"
    error_message = "This foundation is intentionally constrained to us-central1."
  }
}

variable "artifact_repository_id" {
  description = "Artifact Registry Docker repository ID."
  type        = string
  default     = "throughball"
}

variable "service_name" {
  description = "Cloud Run service name for dev."
  type        = string
  default     = "throughball-dev"
}

variable "container_image" {
  description = "Container image to deploy to Cloud Run. Example: us-central1-docker.pkg.dev/PROJECT/throughball/app:TAG"
  type        = string
}

variable "min_instances" {
  description = "Minimum Cloud Run instances. Must remain zero to preserve scale-to-zero behavior."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances == 0
    error_message = "Cloud Run min_instances must be 0 in this low-cost foundation."
  }
}

variable "max_instances" {
  description = "Maximum Cloud Run instances for demo-safe autoscaling."
  type        = number
  default     = 2

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 5
    error_message = "max_instances must be between 1 and 5 for demo-safe autoscaling."
  }
}

variable "allow_unauthenticated" {
  description = "Whether to allow public unauthenticated access to the Cloud Run service."
  type        = bool
  default     = false
}

variable "ingress" {
  description = "Cloud Run ingress setting."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"

  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
    ], var.ingress)
    error_message = "ingress must be a valid Cloud Run v2 ingress enum."
  }
}

variable "secret_ids" {
  description = "Secret Manager secret IDs to create as containers only. Secret values are not managed by Terraform."
  type        = set(string)
  default     = []
}

variable "labels" {
  description = "Additional low-cardinality labels to apply where supported."
  type        = map(string)
  default     = {}
}
