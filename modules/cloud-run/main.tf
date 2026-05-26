resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  name     = var.service_name
  location = var.location
  ingress  = var.ingress
  labels   = var.labels

  template {
    service_account                  = var.service_account_email
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = var.max_instance_request_concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.container_image

      ports {
        container_port = var.container_port
      }

      resources {
        limits            = var.resource_limits
        cpu_idle          = var.cpu_idle
        startup_cpu_boost = var.startup_cpu_boost
      }

      dynamic "env" {
        for_each = var.environment_variables

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_environment_variables

        content {
          name = env.key

          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }

      dynamic "startup_probe" {
        for_each = var.startup_probe_enabled ? [1] : []

        content {
          initial_delay_seconds = 0
          timeout_seconds       = 2
          period_seconds        = 10
          failure_threshold     = 3

          http_get {
            path = var.health_check_path
          }
        }
      }

      dynamic "liveness_probe" {
        for_each = var.liveness_probe_enabled ? [1] : []

        content {
          initial_delay_seconds = 0
          timeout_seconds       = 2
          period_seconds        = 30
          failure_threshold     = 3

          http_get {
            path = var.health_check_path
          }
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "unauthenticated_invoker" {
  count = var.allow_unauthenticated ? 1 : 0

  project  = var.project_id
  location = google_cloud_run_v2_service.this.location
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
