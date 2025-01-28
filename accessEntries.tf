data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_eks_access_entry" "userAdminRole" {
  cluster_name      = aws_eks_cluster.EKSCluster.name
  principal_arn     = "arn:aws:iam::${local.account_id}:user/${var.userName}"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = aws_eks_cluster.EKSCluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::${local.account_id}:user/${var.userName}"

  access_scope {
    type       = "cluster"
  }
}