resource "google_compute_forwarding_rule" "default" {
  name       = "reddit-forwarding-rule"
  region     = "europe-west1"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "9292"
}

resource "google_compute_target_pool" "default" {
  name = "reddit-target-pool"

  instances = [
    "europe-west1-b/reddit-app-0",
    "europe-west1-b/reddit-app-1",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "default"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = "9292"
}
