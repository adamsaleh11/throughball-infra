resource "google_project_iam_member" "runtime_observability_roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = var.member
}
