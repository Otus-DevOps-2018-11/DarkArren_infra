resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "abramov:${file(var.public_key_path)}"
  }

  connection {
  type        = "ssh"
  user        = "abramov"
  agent       = false
  private_key = "${file(var.private_key_path)}"
  }
  provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf",
    "sudo systemctl restart mongod.service",
    ]
  }
}

# Правило firewall
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
