variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "member" {
  description = "IAM member that should receive lightweight observability permissions."
  type        = string
}

variable "roles" {
  description = "Runtime observability roles for logs, metrics, and traces."
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
  ]
}
