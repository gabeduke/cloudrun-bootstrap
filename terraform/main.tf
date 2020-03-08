provider "google" {
  project = var.project_name
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

resource "google_cloud_run_domain_mapping" "service" {
  location = var.service_location
  name     = var.domain

  metadata {
    namespace = var.project_name
  }

  spec {
    route_name = google_cloud_run_service.service.name
  }
}

resource "google_dns_record_set" "cname" {
  name         = "${var.service_name}.${google_dns_managed_zone.leetcloud.dns_name}"
  managed_zone = google_dns_managed_zone.leetcloud.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["ghs.googlehosted.com."]
}

resource "google_dns_managed_zone" "leetcloud" {
  name     = "leetcloud"
  dns_name = "k8s.leetserve.com."
  dnssec_config {
    state = "off"
  }
}

output "url" {
  value = "${google_cloud_run_service.service.status[0].url}"
}
