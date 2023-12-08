# Cluster API AWS Bootstraper (capa-bootstrap)

The Cluster API AWS Boostrapper (or capa-bootstrap) is a Terraform-based tool
that's used to quickly spin up a K3s-backed cluster on a single EC2 instance
with Cluster API and Cluster API AWS installed and ready to be used.

**WARNING:** This is NOT meant to be production-ready! The single EC2 instance
is susceptible to downtime if any failure on the node occurs, and data loss
is expected if the node is recreated for any reason.

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
   (any version greater than v1.0.0)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed your local terminal
3. AWS credentials via an access key and a secret key (optionally a session token for multi-factor auth),
   with permissions to create EC2 instances.
4. [SSH key](https://cluster-api-aws.sigs.k8s.io/topics/using-clusterawsadm-to-fulfill-prerequisites.html#ssh-key-pair) 
   already present in the AWS account for CAPA to use for node access.

## Usage

### Creating the management cluster

1. Provide the AWS authentication data for the configuration:
  - Via a tfvars file:
    1. Create a copy of the (example .tfvars file)[./terraform.tfvars.example]
       provided in the root directory of this repo, and name it "terraform.tfvars".
    2. Fill the `aws_access_key` and `aws_secret_key` variables with appropriate
       key data, and modify any other variables from their defaults as you see fit.
  - Via environment variables:
    1. Export the following variables in your terminal:
    ```
    export TF_VAR_aws_access_key=<YOUR ACCESS KEY>
    export TF_VAR_aws_secret_key=<YOUR SECRET KEY>
    ```
    2. Export any other variables that you'd like to modify, using the prefix
       `TF_VAR_` before the variable name.
2. Perform a `terraform init` followed by a `terraform apply`. If using a
   tfvars file, execute `terraform apply -var-file=<YOUR TFVARS FILE>` instead.
   When performing an apply, you should see the following output:
   ```
   $ terraform apply
   data.aws_ami.latest_ubuntu: Reading...
   data.aws_ami.latest_ubuntu: Read complete after 0s [id=ami-0557a15b87f6559cf]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create
   
   Terraform will perform the following actions:

     # aws_instance.capa_server will be created
     + resource "aws_instance" "capa_server" {
   ...
   ```
   At the prompt, type "yes" to allow Terraform to create your infrastructure.
3. After Terraform has finished creating your infrastructure, you should see
   the following output:
   ```
   Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

   Outputs:

   capa_node_ip = <IP ADDRESS>
   ```
   This IP address is the address of the EC2 instance where your management
   cluster is located. You can start interacting with it using the kubeconfig
   `capa-management.kubeconfig` file that Terraform has created for us in the
   directory where the apply was done from:
   ```
   $ kubectl --kubeconfig capa-management.kubeconfig get nodes
   NAME               STATUS   ROLES                  AGE    VERSION
   ip-172-31-22-202   Ready    control-plane,master   5m5s   v1.25.5+k3s2

   $ kubectl --kubeconfig capa-management.kubeconfig get pods -A
   NAMESPACE                           NAME                                                            READY   STATUS      RESTARTS   AGE
   cert-manager                        cert-manager-cainjector-d9bc5979d-krs7g                         1/1     Running     0          4m55s
   kube-system                         local-path-provisioner-79f67d76f8-gn448                         1/1     Running     0          4m55s
   kube-system                         coredns-597584b69b-np8z2                                        1/1     Running     0          4m55s
   cert-manager                        cert-manager-74d949c895-hqdrt                                   1/1     Running     0          4m55s
   cert-manager                        cert-manager-webhook-84b7ddd796-pstcd                           1/1     Running     0          4m54s
   kube-system                         helm-install-traefik-crd-7j9fk                                  0/1     Completed   0          4m56s
   kube-system                         metrics-server-5f9f776df5-lt6vs                                 1/1     Running     0          4m55s
   kube-system                         svclb-traefik-005a4e24-m9cdb                                    2/2     Running     0          4m32s
   kube-system                         traefik-66c46d954f-hzsdz                                        1/1     Running     0          4m33s
   kube-system                         helm-install-traefik-n7k79                                      0/1     Completed   1          4m56s
   capi-system                         capi-controller-manager-7847d5c678-wkwf6                        1/1     Running     0          4m32s
   capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-64fcd4ff4d-tsj4l      1/1     Running     0          4m21s
   capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-6f86697dc-47lcb   1/1     Running     0          4m17s
   capa-system                         capa-controller-manager-57666b88f6-lr726                        1/1     Running     0          4m9s
   ```
### Creating CAPA-managed clusters

To create CAPA-managed clusters, one can follow the quickstart instructions
provided in [their documentation](https://cluster-api-aws.sigs.k8s.io/getting-started.html#required-configuration-for-common-providers).

Alternatively, you can use the sample YAML files provided in the [examples](./examples)
directory, where one can modify some of the values and create a CAPA-managed
cluster with complete visibility of the control plane, or a CAPA-managed EKS
cluster where the control plane is managed by AWS.

**WARNING:** Clusters can be created by `kubectl apply`'ing the YAML files in
the examples, however you should always clean up CAPA clusters by deleting the
cluster object from the cluster:
```
kubectl delete cluster -n <CAPA CLUSTER NAMESPACE> <CAPA CLUSTER NAME>
```

If the cluster is deleted using the YAML file, the controllers won't be able
to clean up resources properly and could leave lingering objects in the cluster
and in the AWS account that will need to be removed manually.

### Debugging

If needed, the node where the management cluster is installed is accessible
via SSH with the private key `id_rsa` created for the EC2 instance:

```
ssh -i id_rsa ubuntu@<NODE IP ADDRESS>
```
