data "tls_certificate" "OIDCURL" {
  url = aws_eks_cluster.EKSCluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "OPENIDConnector" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.OIDCURL.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.EKSCluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "VPCCNI_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.OPENIDConnector.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.OPENIDConnector.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "VPCCNIROLE" {
  assume_role_policy = data.aws_iam_policy_document.VPCCNI_assume_role_policy.json
  name               = "${var.env_prefix}-AmazonEKSVPCCNIRole"
}

resource "aws_iam_role_policy_attachment" "VPCCNIROLEAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.VPCCNIROLE.name
}

resource "aws_eks_addon" "VPCCNI" {
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn = aws_iam_role.VPCCNIROLE.arn
  depends_on = [aws_eks_cluster.EKSCluster,aws_iam_role.VPCCNIROLE,aws_iam_role_policy_attachment.VPCCNIROLEAttachment]
}

resource "aws_eks_addon" "coreDNS" {
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [aws_eks_cluster.EKSCluster, aws_eks_node_group.EKSCluster]
}