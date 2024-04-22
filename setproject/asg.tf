#Adding autoscaling group in a zone specified in the variables file using an instance group manager as a target


provider "google" {
  project = "ncdygcxaumqqfwlx"
  region  = "us-central1"
}

resource "google_compute_autoscaler" "autoscaler" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.gmigm.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60
  }
}

resource "google_compute_instance_template" "template" {
  provider = google

  name           = "my-instance-template"
  machine_type   = "e2-medium"
  can_ip_forward = false

  disk {
    source_image = data.google_compute_image.debian_11.id
  }

  network_interface {
    network = google_compute_network.global_vpc.name
  }


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
#where to add ports
resource "google_compute_target_pool" "tgpool" {
  provider = google-beta

  name = "my-target-pool"
}

resource "google_compute_instance_group_manager" "gmigm" {
  name = "my-igm"
  zone = "us-central1-f"
#
#
#
#Working on ports
#
#
#
  named_port {
    name = "http"
    port = 80
  }


  version {
    instance_template = google_compute_instance_template.template.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.tgpool.id]
  base_instance_name = "autoscaler-sample"
}

data "google_compute_image" "debian_11" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_target_pool" "default" {
  name = "my-target-pool"
}
