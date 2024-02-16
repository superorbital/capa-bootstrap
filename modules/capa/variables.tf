# Required
variable "node_public_ip" {
  type        = string
  description = "Public IP of the cluster node"
}

variable "node_internal_ip" {
  type        = string
  description = "Internal IP of the cluster node"
  default     = ""
}

# Required
variable "aws_access_key" {
  type        = string
  sensitive   = true
  description = "AWS access key used to create infrastructure"
}

# Required
variable "aws_secret_key" {
  type        = string
  sensitive   = true
  description = "AWS secret key used to create AWS infrastructure"
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token used to create AWS infrastructure"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "us-east-1"
}

# Required
variable "node_username" {
  type        = string
  description = "Username used for SSH access to the cluster node"
}

# Required
variable "ssh_private_key_pem" {
  type        = string
  description = "Private key used for SSH access to the cluster node"
}

variable "k3s_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for k3s management cluster"
  default     = "v1.28.6+k3s2"
}

variable "capa_version" {
  type        = string
  description = "Cluster API Provider AWS version (format: v0.0.0)"
  default     = "v2.3.1"
}

variable "capi_version" {
  type        = string
  description = "Cluster API version (format v0.0.0)"
  default     = "v1.6.1"
}

variable "experimental_features" {
  type        = list(string)
  description = "List of experimental CAPI features to enable, e.g. [\"EXP_CLUSTER_RESOURCE_SET: true\"]"
  default     = []
}