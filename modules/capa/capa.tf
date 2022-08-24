resource "ssh_resource" "install_capa" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = var.node_public_ip
  pre_commands = [
    "curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${var.capa_version}/clusterawsadm-linux-amd64 -o clusterawsadm",
    "chmod +x clusterawsadm",
    "sudo mv clusterawsadm /usr/local/bin"
  ]
  commands    = ["clusterawsadm version"]
  user        = var.node_username
  private_key = var.ssh_private_key_pem
}
