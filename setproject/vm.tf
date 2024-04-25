provider "google" {
  project = "bqyktkqbwbbxihtw"
  region  = "us-central1"
}

resource "google_compute_instance" "vm" {
  name         = "example-instance"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

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