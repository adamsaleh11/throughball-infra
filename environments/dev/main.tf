locals {
  labels = merge(
    {
      app         = var.app_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )

  referenced_secret_ids = toset(flatten([
    for service in values(var.cloud_run_services) : [
      for secret_ref in values(service.secret_environment_variables) : secret_ref.secret
    ]
  ]))

  secret_ids = setunion(var.secret_ids, local.referenced_secret_ids)

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
  secret_ids = local.secret_ids
  labels     = local.labels

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_iam_member" "runtime_secret_accessor" {
  for_each = local.referenced_secret_ids

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = module.iam.service_account_member

  depends_on = [module.secrets]
}

module "cloud_run" {
  for_each = var.cloud_run_services

  source = "../../modules/cloud-run"

  project_id                       = var.project_id
  location                         = var.region
  service_name                     = each.value.service_name
  container_image                  = each.value.container_image
  service_account_email            = module.iam.service_account_email
  min_instances                    = each.value.min_instances
  max_instances                    = each.value.max_instances
  ingress                          = each.value.ingress
  allow_unauthenticated            = each.value.allow_unauthenticated
  labels                           = merge(local.labels, { service = each.key })
  environment_variables            = each.value.environment_variables
  secret_environment_variables     = each.value.secret_environment_variables
  startup_cpu_boost                = each.value.startup_cpu_boost
  container_port                   = each.value.container_port
  max_instance_request_concurrency = each.value.max_instance_request_concurrency
  resource_limits                  = each.value.resource_limits
  cpu_idle                         = each.value.cpu_idle
  health_check_path                = each.value.health_check_path
  startup_probe_enabled            = each.value.startup_probe_enabled
  liveness_probe_enabled           = each.value.liveness_probe_enabled

  depends_on = [
    google_project_service.required,
    module.artifact_registry,
    module.iam,
    module.observability,
    google_secret_manager_secret_iam_member.runtime_secret_accessor,
  ]
}
