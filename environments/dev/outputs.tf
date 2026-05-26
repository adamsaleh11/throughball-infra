output "artifact_registry_repository_id" {
  description = "Artifact Registry repository ID."
  value       = module.artifact_registry.repository_id
}

output "artifact_registry_repository_name" {
  description = "Full Artifact Registry repository resource name."
  value       = module.artifact_registry.repository_name
}

output "cloud_run_service_names" {
  description = "Cloud Run service names keyed by logical service."
  value       = { for key, service in module.cloud_run : key => service.service_name }
}

output "cloud_run_service_uris" {
  description = "Cloud Run service URIs keyed by logical service."
  value       = { for key, service in module.cloud_run : key => service.service_uri }
}

output "runtime_service_account_email" {
  description = "Runtime service account email used by Cloud Run."
  value       = module.iam.service_account_email
}

output "secret_ids" {
  description = "Secret containers managed by Terraform."
  value       = module.secrets.secret_ids
}
