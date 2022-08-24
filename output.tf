output "capa_node_ip" {
  value = aws_instance.capa_server.public_ip
}

output "result" {
  value = module.capa.install_results
}
