variable "public_key_path" {
  description = "Path to the public key used to connect to instance"
}

variable "zone" {
  description = "Zone"
}

variable "db_disk_image" {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}

variable "machine_type" {
  description = "Machine type"
  default     = "g1-small"
}

variable "private_key_path" {
  description = "Path to the private key used to run provisioners"
}

