provider "google" {
  project = "bqyktkqbwbbxihtw"
  region  = "us-central1"
}

#Allowing HTTP
resource "google_compute_firewall" "http_firewall" {
  name    = "allow-http"
  network = google_compute_network.global_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  
  target_tags   = ["http-server"]
}

#Creating VM
resource "google_compute_instance" "vm" {
  name         = "example-instance"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"
  tags = ["http-server"]


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.global_vpc.name
    access_config {
      // This will create a public IP for the instance
    }
  }

  metadata_startup_script = "echo 'Hello Oleksii' > /var/www/html/index.html && sudo systemctl restart apache2"
}