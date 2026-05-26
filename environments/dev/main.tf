locals {
  labels = merge(
    {
      app         = var.app_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )

  required_services = toset([
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudtrace.googleapis.com",
  ])
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = var.region
  repository_id = var.artifact_repository_id
  labels        = local.labels

  depends_on = [google_project_service.required]
}

module "iam" {
  source = "../../modules/iam"

  project_id   = var.project_id
  account_id   = "throughball-dev-runner"
  display_name = "Throughball dev Cloud Run runtime"
  project_roles = [
    "roles/artifactregistry.reader",
  ]

  depends_on = [google_project_service.required]
}

module "observability" {
  source = "../../modules/observability"

  project_id = var.project_id
  member     = module.iam.service_account_member

  depends_on = [google_project_service.required]
}

module "secrets" {
  source = "../../modules/secrets"

  project_id = var.project_id
  secret_ids = var.secret_ids
  labels     = local.labels

  depends_on = [google_project_service.required]
}

module "cloud_run" {
  source = "../../modules/cloud-run"

  project_id            = var.project_id
  location              = var.region
  service_name          = var.service_name
  container_image       = var.container_image
  service_account_email = module.iam.service_account_email
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  ingress               = var.ingress
  allow_unauthenticated = var.allow_unauthenticated
  labels                = local.labels
  environment_variables = {}
  startup_cpu_boost     = false
  container_port        = 8080

  depends_on = [
    google_project_service.required,
    module.artifact_registry,
    module.iam,
    module.observability,
  ]
}
