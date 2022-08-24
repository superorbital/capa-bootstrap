# Required
variable "aws_access_key" {
  type        = string
  sensitive   = true
  description = "AWS access key used for account access"
}

# Required
variable "aws_secret_key" {
  type        = string
  sensitive   = true
  description = "AWS secret key used for account access"
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token for account access (if using MFA)"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "us-east-1"
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "superorbital-quickstart"
}

variable "instance_type" {
  type        = string
  description = "Instance type used for all EC2 instances"
  default     = "t3a.medium"
}

variable "k3s_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
  default     = "v1.24.3+k3s1"
}

variable "capa_version" {
  type        = string
  description = "Cluster API Provider AWS version (format: v0.0.0)"
  default     = "v1.5.0"
}

variable "capi_version" {
  type        = string
  description = "Cluster API version (format v0.0.0)"
  default     = "v1.2.1"
}

locals {
  node_username = "ubuntu"
}
