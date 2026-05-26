output "service_account_email" {
  description = "Runtime service account email."
  value       = google_service_account.runtime.email
}

output "service_account_member" {
  description = "Runtime service account IAM member string."
  value       = google_service_account.runtime.member
}
