# EKSClusterCreationTerraform
Simple EKS cluster creation with EKS managed nodes

# Prerequisites
* User should have the AWS Account - https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html
* Git should be installed.
    * https://git-scm.com/downloads/win - for Windows
    * https://git-scm.com/downloads/linux - for Linux
* Kubectl should be installed - https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
* Terraform should be installed - https://developer.hashicorp.com/terraform/install
* AWSCLI should be installed - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* IAM User to create cluster or a user which you want to provide admin access to your cluster - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

# Steps to use the code

1. Clone the repo.
2. Navigate to the direcotry EKSClusterCreationTerraform
3. change the default variables if required as per your requirement.
4. Initate the terraform using the following command.
    * terraform init
4. Execute the following terraform commands if you want to execute the code with default values else you can use -var-file=dev.tfvars at the end of the following commands.
    * terraform plan - please check what all resources are being created.
    * terraform apply - approve the execution.
5. Check the resources in AWS.
6. Configure your system to comminicate with your cluster with the following command.
    * aws eks update-kubeconfig --region <em>region-code</em> --name </em>my-cluster</em>
    * kubectl get svc - You should get the following result
    ![alt text](image.png) 
    if you are unable to get the result, add the IAM user in access tab of cluster - https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html

# Sanity testing

1. Check whether the nodes are ready or not using the following command.
    * kubectl get nodes
    
        ![alt text](image-3.png)
2. Check whether all addons are created or not. 
3. If ready, terminate the node from EC2 console, new node should be launched automatically and check whether the new instance is ready or not.
4. Create a deployment with nginx image
    * kubectl create deploy nginx --replicas 2 --image nginx:latest
    ![alt text](image-2.png)

# Access control

* To provide access to the cluster we can levarage the access entries of EKS, for example, we can provide the developer access with the proper predefined access policy - For better understanding - go through https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html

# Destroy post testing if cluster is not required.

1. Execute the following command to destroy.
    * terraform destroy
    
        ![alt text](image-1.png)

