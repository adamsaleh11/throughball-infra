variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "secret_ids" {
  description = "Secret IDs to create as containers only. Values and versions are not managed here."
  type        = set(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to secrets."
  type        = map(string)
  default     = {}
}
