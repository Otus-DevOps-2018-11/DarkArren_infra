variable "public_key_path" {
  description = "Path to the public key used to connect to instance"
}

variable "private_key_path" {
  description = "Path to the private key used to run provisioners"
}
variable "zone" {
  description = "Zone"
}

variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable "machine_type" {
  description = "Machine type"
  default     = "g1-small"
}

variable "firewall_tags" {
  description = "Firewall rule tag for applicationa"
  default     = ["app"]
}

variable "firewall_source_ranges" {
  description = "Firewall rule source ranges"
  default     = ["0.0.0.0/0"]
}
variable "db_internal_address" {
  description = "MongoDB internal IP"
  default = "127.0.0.1"
}

