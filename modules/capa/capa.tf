resource "ssh_resource" "install_capa" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  triggers = {
    bootstrap_config_contents = filesha256("${path.module}/config/bootstrap-iam-configuration.yaml")
    aws_config_tpl_contents   = filesha256("${path.module}/config/aws-config.tftpl")
    aws_creds_tpl_contents    = filesha256("${path.module}/config/aws-credentials.tftpl")
  }

  host        = var.node_public_ip
  user        = var.node_username
  private_key = var.ssh_private_key_pem

  pre_commands = [
    "curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/${var.capi_version}/clusterctl-linux-amd64 -o clusterctl",
    "chmod +x ./clusterctl",
    "sudo mv ./clusterctl /usr/local/bin/clusterctl",
    "curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${var.capa_version}/clusterawsadm-linux-amd64 -o clusterawsadm",
    "chmod +x clusterawsadm",
    "sudo mv clusterawsadm /usr/local/bin",
    "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k.yaml",
    "sudo chown ${var.node_username}:${var.node_username} /tmp/k.yaml",
    "mkdir -p /home/${var.node_username}/.aws"
  ]

  file {
    source      = "${path.module}/config/bootstrap-iam-configuration.yaml"
    permissions = "0644"
    destination = "/tmp/bootstrap-config.yaml"
  }

  file {
    content     = templatefile("${path.module}/config/aws-config.tftpl", { aws_region = var.aws_region })
    permissions = "0600"
    destination = "/home/${var.node_username}/.aws/config"
  }

  file {
    content     = templatefile("${path.module}/config/aws-credentials.tftpl", { aws_access_key = var.aws_access_key, aws_secret_key = var.aws_secret_key })
    permissions = "0600"
    destination = "/home/${var.node_username}/.aws/credentials"
  }

  commands = [
    "clusterawsadm bootstrap iam create-cloudformation-stack --config=/tmp/bootstrap-config.yaml",
    <<EOT
    export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
    clusterctl init --infrastructure aws --kubeconfig=/tmp/k.yaml
    EOT
  ]
}
