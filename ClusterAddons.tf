data "tls_certificate" "OIDCURL" {
  count = var.vpc_CNI_addon_required ? 1: 0
  url = aws_eks_cluster.EKSCluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "OPENIDConnector" {
  count = var.vpc_CNI_addon_required ? 1: 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.OIDCURL[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.EKSCluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "VPCCNI_assume_role_policy" {
  count = var.vpc_CNI_addon_required ? 1: 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider[0].OPENIDConnector.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider[0].OPENIDConnector.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "VPCCNIROLE" {
  count = var.vpc_CNI_addon_required ? 1: 0
  assume_role_policy = data.aws_iam_policy_document[0].VPCCNI_assume_role_policy.json
  name               = "${var.env_prefix}-AmazonEKSVPCCNIRole"
}

resource "aws_iam_role_policy_attachment" "VPCCNIROLEAttachment" {
  count = var.vpc_CNI_addon_required ? 1: 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role[0].VPCCNIROLE.name
}

resource "aws_eks_addon" "VPCCNI" {
  count = var.vpc_CNI_addon_required ? 1: 0
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn = aws_iam_role.VPCCNIROLE.arn
  depends_on = [aws_eks_cluster.EKSCluster,aws_iam_role.VPCCNIROLE,aws_iam_role_policy_attachment.VPCCNIROLEAttachment]
}

resource "aws_eks_addon" "coreDNS" {
  count = var.coreDNS_addon_required ? 1: 0
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [aws_eks_cluster.EKSCluster, aws_eks_node_group.EKSCluster]
}

resource "aws_eks_addon" "kubeProxy" {
  count = var.kubeProxy_addon_required ? 1: 0
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [aws_eks_cluster.EKSCluster, aws_eks_node_group.EKSCluster]
}

resource "aws_eks_addon" "eksPodIdentityAgent" {
  count = var.eks_pod_identity_agent_addon_required ? 1: 0
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [aws_eks_cluster.EKSCluster, aws_eks_node_group.EKSCluster]
}