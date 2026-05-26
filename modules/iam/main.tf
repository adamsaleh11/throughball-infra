resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
  description  = "Runtime identity for Cloud Run in the Terraform-managed environment."
}

resource "google_project_iam_member" "runtime_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.runtime.member
}
