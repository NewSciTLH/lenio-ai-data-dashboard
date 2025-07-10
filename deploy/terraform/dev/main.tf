provider "google" {
  project = var.PROJECT
  region  = var.REGION
}

resource "google_cloud_run_service" "default" {
  name     = var.CLOUD_SERVICE_NAME
  location = var.REGION

  metadata {
    labels = {
      "cost-center": "callsimulatorv1-dev"
      "vanta-owner": "jeremy-quinto"
      "vanta-non-prod": "true"
      "vanta-description": "lenio-ai-data-dashboard-dev"
      "vanta-contains-user-data": "true"
      "vanta-user-data-stored": "user-object-and-token"
      "vanta-no-alert": "lenio-ai-data-dashboard-dev"
    }
  }

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
      }
      labels = {
        "cost-center": "callsimulatorv1-dev"
      }
    }
    spec {
    #   service_account_name = var.service_account
      containers {
        image = var.CONTAINER_IMAGE
        ports {
          container_port = 3000
        }
        resources {
          limits = {
            cpu = "1000m"
            memory = "256Mi"
          }
        }

        dynamic "env" {
          for_each = var.ENVS
          content {
            name = env.key
            value = env.value
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# resource "null_resource" "checking_envs" {
#     for_each = var.ENVS
#     provisioner "local-exec" {
#         command = "echo '${each.key}: ${each.value}'"
#     }
# }