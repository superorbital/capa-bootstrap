resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "capa_bootstrap_key_pair" {
  key_name_prefix = "${var.prefix}-capa-bootstrap-"
  public_key      = tls_private_key.global_key.public_key_openssh
}

# Security group to allow all traffic
resource "aws_security_group" "capa_bootstrap_sg_allowall" {
  name        = "${var.prefix}-capa-bootstrap-allowall"
  description = "CAPA Bootstrap - allow all traffic"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "capa-bootstrap"
  }
}

# AWS EC2 instance for creating a single node cluster
resource "aws_instance" "capa_server" {
  ami           = var.ami_id == "" ? data.aws_ami.latest_ubuntu.id : var.ami_id
  instance_type = var.instance_type

  key_name               = aws_key_pair.capa_bootstrap_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.capa_bootstrap_sg_allowall.id]

  root_block_device {
    volume_size = 40
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = local.node_username
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  tags = {
    Name  = "${var.prefix}-capa-server"
    Owner = "capa-bootstrap"
  }
}

# Cluster API AWS resources
module "capa" {
  source = "./modules/capa"

  node_public_ip         = aws_instance.capa_server.public_ip
  node_internal_ip       = aws_instance.capa_server.private_ip
  node_username          = local.node_username
  ssh_private_key_pem    = tls_private_key.global_key.private_key_pem
  k3s_kubernetes_version = var.k3s_kubernetes_version
  capa_version           = var.capa_version
  capi_version           = var.capi_version
  experimental_features  = var.experimental_features

  aws_access_key    = var.aws_access_key
  aws_secret_key    = var.aws_secret_key
  aws_session_token = var.aws_session_token
  aws_region        = var.aws_region
}
