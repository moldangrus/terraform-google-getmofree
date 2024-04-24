resource "google_compute_autoscaler" "default" {
  provider = google-beta

  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.example_group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    metric {
      name                       = "pubsub.googleapis.com/subscription/num_undelivered_messages"
      filter                     = "resource.type = pubsub_subscription AND resource.label.subscription_id = our-subscription"
      single_instance_assignment = 65535
    }
  }
}

resource "google_compute_instance_template" "example_template" {
  name        = "example-template"
  machine_type = "n1-standard-1"
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
  }
  network_interface {
    network = "global_vpc"
    access_config {}
  }
  metadata_startup_script = file("startup.sh")
}
resource "google_compute_instance_group_manager" "example_group" {
  name        = "example-group"
  base_instance_name = "example-instance"
  zone        = "us-central1-a"
  target_size = 1

    version {
    instance_template  = google_compute_instance_template.example_template.self_link_unique
  }
  named_port {
    name = "http"
    port = 80
  }
 }


resource "google_compute_target_pool" "example_pool" {
  name             = "example-pool"
  region           = "us-central1"
  health_checks    = ["${google_compute_http_health_check.example.name}"]
}
resource "google_compute_http_health_check" "example" {
  name               = "example-check"
  check_interval_sec = 1
  timeout_sec        = 1
  healthy_threshold  = 1
  unhealthy_threshold = 1
  port               = 80
}
resource "google_compute_forwarding_rule" "example_forwarding_rule" {
  name                  = "example-forwarding-rule"
  target                = google_compute_target_http_proxy.example_proxy.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}
resource "google_compute_target_http_proxy" "example_proxy" {
  name        = "example-proxy"
  url_map     = google_compute_url_map.example_url_map.self_link
}
resource "google_compute_url_map" "example_url_map" {
  name            = "example-url-map"
  default_service = google_compute_backend_service.example_backend_service.self_link
}
resource "google_compute_backend_service" "example_backend_service" {
  name = "example-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  health_checks = ["${google_compute_http_health_check.example.name}"]
  backend {
    group = google_compute_instance_group_manager.example_group.instance_group
  }
}
output "load_balancer_ip" {
  value = google_compute_forwarding_rule.example_forwarding_rule.ip_address
}
