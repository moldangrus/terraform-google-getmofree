#Setting provider for ASG
provider "google-beta" {
    region = "us-central1"
    zone   = "us-central-a"
  
}
provider "google" {
  project = "ncdygcxaumqqfwlx"
  region  = "us-central1"
}