provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  private_key_path = "${var.private_key_path}"
}

module "app" {
  source              = "../modules/app"
  public_key_path     = "${var.public_key_path}"
  zone                = "${var.zone}"
  app_disk_image      = "${var.app_disk_image}"
  private_key_path    = "${var.private_key_path}"
  db_internal_address = "${module.db.db_internal_ip}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

# data "terraform_remote_state" "stage" {
#   backend = "gcs"

#   config {
#     bucket = "storage-bucket-darkarren-stage"
#     prefix = "stage"
#   }
# }
