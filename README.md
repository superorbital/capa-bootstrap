# Cluster API AWS Bootstraper (capa-bootstrap)

The Cluster API AWS Boostrapper (or capa-bootstrap) is a Terraform-based tool
that's used to quickly spin up a K3s-backed cluster on a single EC2 instance
with Cluster API and Cluster API AWS installed and ready to be used.

**WARNING** This is NOT meant to be production-ready! The single EC2 instance
is susceptible to downtime if any failure on the node occurs, and data loss
is expected if the node is recreated for any reason.

## Prerequisites

1. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed your local terminal
2. AWS credentials via an access key and a secret key (optionally a session token for multi-factor auth)
3. [SSH key](https://cluster-api-aws.sigs.k8s.io/topics/using-clusterawsadm-to-fulfill-prerequisites.html#ssh-key-pair) 
  already present in the AWS account to use for node access

## Usage

### Debugging

If needed, the node where the management cluster is installed is accessible
via SSH with the private key `id_rsa` created for the ec2 instance:

```
ssh -i id_rsa ubuntu@<NODE IP ADDRESS>
```
