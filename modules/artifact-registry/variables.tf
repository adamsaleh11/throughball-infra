variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "location" {
  description = "Artifact Registry location."
  type        = string
}

variable "repository_id" {
  description = "Artifact Registry repository ID."
  type        = string
}

variable "description" {
  description = "Artifact Registry repository description."
  type        = string
  default     = "Throughball Docker images"
}

variable "labels" {
  description = "Labels to apply to the repository."
  type        = map(string)
  default     = {}
}
