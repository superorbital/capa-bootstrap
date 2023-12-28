output "capa_node_ip" {
  value       = aws_instance.capa_server.public_ip
  description = "Public IP address of the CAPA management node. Useful for SSH purposes."
}
