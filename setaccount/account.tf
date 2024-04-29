

#Searching for billing account
data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

#Creating unique ID for the project
resource "random_string" "string" {
  length  = 16
  numeric = false
  special = false
  lower   = true
  upper   = false
}

#Creating Google project with unique ID and "GCP Project" name
resource "google_project" "gcpproject" {
  name            = "GCP Project"
  project_id      = random_string.string.result
  billing_account = data.google_billing_account.acct.id
}

#Assigning resources to the project
resource "null_resource" "set-project" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud config set project ${google_project.gcpproject.project_id}"
  }
}
