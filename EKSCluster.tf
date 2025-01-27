resource "aws_iam_role" "myAmazonEKSClusterRole" {
  name = "${var.env_prefix}-myAmazonEKSClusterRole"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
			},
      "Action": "sts:AssumeRole"
			}
		]
	})
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.myAmazonEKSClusterRole.name
}

resource "aws_eks_cluster" "EKSCluster" {
  name = "${var.env_prefix}-EKSCluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.myAmazonEKSClusterRole.arn
  version  = var.EKSClusterVersion

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_vpc_PublicSubnet02.id,
      aws_subnet.eks_vpc_PublicSubnet01.id,
      aws_subnet.eks_vpc_PrivateSubnet02.id,
      aws_subnet.eks_vpc_PrivateSubnet01.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}
