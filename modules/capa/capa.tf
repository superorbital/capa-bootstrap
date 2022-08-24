resource "ssh_resource" "install_capa" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = var.node_public_ip
  pre_commands = [
    "curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/${var.capi_version}/clusterctl-linux-amd64 -o clusterctl",
    "chmod +x ./clusterctl",
    "sudo mv ./clusterctl /usr/local/bin/clusterctl",
    "curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${var.capa_version}/clusterawsadm-linux-amd64 -o clusterawsadm",
    "chmod +x clusterawsadm",
    "sudo mv clusterawsadm /usr/local/bin",
    "mkdir -p .aws",
    "echo -e '[default] \nregion = ${var.aws_region} \noutput = json' > .aws/config",
    "echo -e '[default] \naws_access_key_id = ${var.aws_access_key} \naws_secret_access_key = ${var.aws_secret_key}' > .aws/credentials",
    "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k.yaml",
    "sudo chown ${var.node_username}:${var.node_username} /tmp/k.yaml"
  ]

  commands = [
    "clusterawsadm bootstrap iam create-cloudformation-stack",
    <<EOT
    export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
    clusterctl init --infrastructure aws --kubeconfig=/tmp/k.yaml
    EOT
  ]

  user        = var.node_username
  private_key = var.ssh_private_key_pem
}
