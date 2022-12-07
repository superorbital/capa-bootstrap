resource "ssh_resource" "install_capa" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  triggers = {
    capi_version              = var.capi_version
    capa_version              = var.capa_version
    bootstrap_config_contents = filesha256("${path.module}/config/bootstrap-iam-configuration.yaml")
    aws_config_tpl_contents   = filesha256("${path.module}/config/aws-config.tftpl")
    aws_creds_tpl_contents    = filesha256("${path.module}/config/aws-credentials.tftpl")
    aws_tpl_contents          = filesha256("${path.module}/config/aws.tftpl")
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
    "mkdir -p /home/${var.node_username}/.aws",
    "mkdir -p /home/${var.node_username}/.cluster-api",
    "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k.yaml",
    "sudo chown ${var.node_username}:${var.node_username} /tmp/k.yaml",
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

  file {
    content     = templatefile("${path.module}/config/clusterctl.tftpl", { clusterctl_experimental_features = join("\n", var.experimental_features), aws_b64encoded_credentials = base64encode(templatefile("${path.module}/config/aws.tftpl", { aws_access_key = var.aws_access_key, aws_secret_key = var.aws_secret_key, aws_region = var.aws_region })) })
    permissions = "0600"
    destination = "/home/${var.node_username}/.cluster-api/clusterctl.yaml"
  }

  commands = [
    "clusterawsadm bootstrap iam create-cloudformation-stack --config=/tmp/bootstrap-config.yaml",
    "clusterctl init --infrastructure aws --kubeconfig=/tmp/k.yaml"
  ]
}
