provider "google" {
  project = "bqyktkqbwbbxihtw"
  region  = "us-central1"
}

resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "global_vpc"
    access_config {
      // This will create a public IP for the instance
    }
  }

  metadata_startup_script = "echo 'Hello Oleksii' > /var/www/html/index.html && sudo systemctl restart apache2"
}