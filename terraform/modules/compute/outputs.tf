output "ip_address" {
  value = google_compute_address.static_ip.address
}
output "instance_name" {
  value = google_compute_instance.minecraft_server_host.name
}
