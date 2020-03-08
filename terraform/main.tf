provider "google" {
  project = "leetcloud-173303"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "service" {
  name     = var.service_name
  location = var.service_location

  template {
    spec {
      containers {
        image = var.service_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.run]
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.service.name
  location = google_cloud_run_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = "${google_cloud_run_service.service.status[0].url}"
}
