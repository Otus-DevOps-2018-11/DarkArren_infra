output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

# output "forwarding_rule_external_ip" {
#   value = "${google_compute_forwarding_rule.default.ip_address}"
# }


# output "app2_external_ip" {
#   value = "${google_compute_instance.app.1.network_interface.0.access_config.0.assigned_nat_ip}"
# }

