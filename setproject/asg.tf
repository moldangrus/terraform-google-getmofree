
# Define the firewall rule to allow HTTP traffic
resource "google_compute_firewall" "http" {
  name    = "http"
  network = google_compute_network.global_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Define the instance template
resource "google_compute_instance_template" "example_template" {
  name        = "example-template"
  machine_type = "n1-standard-1"
  disk {
    source_image = "ubuntu-2004-lts"
    auto_delete  = true
  }
  network_interface {
    network = google_compute_network.global_vpc.self_link
    access_config {
      
    }
  }
  metadata_startup_script = "echo 'Hello, World!' > index.html"
}
# Define the managed instance group
resource "google_compute_instance_group_manager" "example_group" {
  name        = "example-group"
  base_instance_name = "example-instance"
  zone        = "us-central1-a"
  target_size = 1
  instance_template = google_compute_instance_template.example_template.self_link
  named_port {
    name = "http"
    port = 80
  }
}
# Define the HTTP health check
resource "google_compute_http_health_check" "http_health_check" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
# Define the backend service
resource "google_compute_backend_service" "backend_service" {
  name             = "backend-service"
  protocol         = "HTTP"
  timeout_sec      = 30
  port_name        = "http"
  health_checks    = [google_compute_http_health_check.http_health_check.self_link]
}
# Define the URL map
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}
# Define the target HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}
# Define the global forwarding rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
}