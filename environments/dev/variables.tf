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
  default     = 1

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 1
    error_message = "max_instances must be 1 for demo-safe dev autoscaling."
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

variable "cloud_run_services" {
  description = "Dev Cloud Run services keyed by logical service name."
  type = map(object({
    service_name = string
    container_image = optional(
      string,
      "us-central1-docker.pkg.dev/your-gcp-project-id/throughball/placeholder:dev"
    )
    min_instances                    = optional(number, 0)
    max_instances                    = optional(number, 1)
    ingress                          = optional(string, "INGRESS_TRAFFIC_ALL")
    allow_unauthenticated            = optional(bool, false)
    environment_variables            = optional(map(string), {})
    secret_environment_variables     = optional(map(object({ secret = string, version = optional(string, "latest") })), {})
    container_port                   = optional(number, 8080)
    max_instance_request_concurrency = optional(number, 10)
    resource_limits                  = optional(map(string), { cpu = "1", memory = "512Mi" })
    cpu_idle                         = optional(bool, true)
    startup_cpu_boost                = optional(bool, false)
    health_check_path                = optional(string, "/health")
    startup_probe_enabled            = optional(bool, true)
    liveness_probe_enabled           = optional(bool, true)
  }))
  default = {
    platform_api = {
      service_name = "throughball-platform-api"
    }
    ai_runtime = {
      service_name = "throughball-ai-runtime"
    }
    mcp_server = {
      service_name = "throughball-mcp-server"
    }
    worker = {
      service_name           = "throughball-worker"
      liveness_probe_enabled = false
    }
  }

  validation {
    condition     = alltrue([for service in values(var.cloud_run_services) : service.min_instances == 0])
    error_message = "All dev Cloud Run services must use min_instances = 0."
  }

  validation {
    condition     = alltrue([for service in values(var.cloud_run_services) : service.max_instances <= 1])
    error_message = "All dev Cloud Run services must use max_instances <= 1."
  }

  validation {
    condition = alltrue([
      for service in values(var.cloud_run_services) : contains([
        "INGRESS_TRAFFIC_ALL",
        "INGRESS_TRAFFIC_INTERNAL_ONLY",
        "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
      ], service.ingress)
    ])
    error_message = "Each Cloud Run service ingress value must be a valid Cloud Run v2 ingress enum."
  }
}

variable "labels" {
  description = "Additional low-cardinality labels to apply where supported."
  type        = map(string)
  default     = {}
}
