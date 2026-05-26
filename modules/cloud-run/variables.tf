variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "location" {
  description = "Cloud Run service location."
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name."
  type        = string
}

variable "container_image" {
  description = "Container image to deploy."
  type        = string
}

variable "service_account_email" {
  description = "Runtime service account email."
  type        = string
}

variable "min_instances" {
  description = "Minimum Cloud Run instances. Must be zero."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances == 0
    error_message = "Cloud Run min_instances must be 0."
  }
}

variable "max_instances" {
  description = "Maximum Cloud Run instances."
  type        = number
  default     = 1
}

variable "ingress" {
  description = "Cloud Run ingress setting."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "allow_unauthenticated" {
  description = "Whether to allow unauthenticated invocations."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the service."
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Plain environment variables for the Cloud Run container."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret Manager-backed environment variables for the Cloud Run container."
  type = map(object({
    secret  = string
    version = optional(string, "latest")
  }))
  default = {}
}

variable "container_port" {
  description = "Container port exposed by the service."
  type        = number
  default     = 8080
}

variable "max_instance_request_concurrency" {
  description = "Maximum concurrent requests per Cloud Run instance."
  type        = number
  default     = 10
}

variable "startup_cpu_boost" {
  description = "Whether to enable Cloud Run startup CPU boost."
  type        = bool
  default     = false
}

variable "resource_limits" {
  description = "Container resource limits."
  type        = map(string)
  default = {
    cpu    = "1"
    memory = "512Mi"
  }
}

variable "cpu_idle" {
  description = "Whether CPU is only allocated during requests."
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "HTTP path used by Cloud Run health probes."
  type        = string
  default     = "/health"
}

variable "startup_probe_enabled" {
  description = "Whether to configure a startup probe."
  type        = bool
  default     = true
}

variable "liveness_probe_enabled" {
  description = "Whether to configure a liveness probe."
  type        = bool
  default     = true
}
