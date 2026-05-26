variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "account_id" {
  description = "Service account ID."
  type        = string
}

variable "display_name" {
  description = "Human-readable service account display name."
  type        = string
}

variable "project_roles" {
  description = "Minimal project roles granted to the runtime service account."
  type        = list(string)
  default     = []
}
