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
  default     = "m5a.large"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for the management EC2 instance"
  default     = ""
}

variable "k3s_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for k3s management cluster"
  default     = "v1.32.3+k3s1"
}

variable "capa_version" {
  type        = string
  description = "Cluster API Provider AWS version (format: v0.0.0)"
  default     = "v2.8.2"
}

variable "capi_version" {
  type        = string
  description = "Cluster API version (format v0.0.0)"
  default     = "v1.9.6"
}

variable "experimental_features" {
  type        = list(string)
  description = "List of experimental CAPI features to enable, e.g. [\"EXP_CLUSTER_RESOURCE_SET: true\"]"
  default     = ["EXP_CLUSTER_RESOURCE_SET: true"]
}

locals {
  node_username = "ubuntu"
}
