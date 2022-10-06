resource "local_file" "kube_config_server_yaml" {
  filename        = format("%s/%s", path.root, "capa-management.kubeconfig")
  file_permission = "0644"
  content         = ssh_resource.retrieve_config.result
}
