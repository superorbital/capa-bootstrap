resource "ssh_resource" "install_capa" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  triggers = {
    bootstrap_config_contents = filesha256("./modules/capa/config/bootstrap-iam-configuration.yaml")
  }

  host        = var.node_public_ip
  user        = var.node_username
  private_key = var.ssh_private_key_pem

  file {
    source      = "./modules/capa/config/bootstrap-iam-configuration.yaml"
    permissions = "0644"
    destination = "/tmp/bootstrap-config.yaml"
  }

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
    "clusterawsadm bootstrap iam create-cloudformation-stack --config=/tmp/bootstrap-config.yaml",
    <<EOT
    export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
    clusterctl init --infrastructure aws --kubeconfig=/tmp/k.yaml
    EOT
  ]
}
