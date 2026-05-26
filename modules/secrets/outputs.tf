output "secret_ids" {
  description = "Secret IDs managed as containers."
  value       = keys(google_secret_manager_secret.this)
}

output "secret_names" {
  description = "Full Secret Manager resource names."
  value       = { for id, secret in google_secret_manager_secret.this : id => secret.name }
}
