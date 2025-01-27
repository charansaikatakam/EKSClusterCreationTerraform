resource "aws_iam_role" "myAmazonEKSNodeRole" {
  name = "${var.env_prefix}-myAmazonEKSNodeRole"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
        }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "Node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.myAmazonEKSNodeRole.name
}
resource "aws_iam_role_policy_attachment" "Node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.myAmazonEKSNodeRole.name
}
resource "aws_iam_role_policy_attachment" "Node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.myAmazonEKSNodeRole.name
}

resource "aws_eks_node_group" "EKSCluster" {
  cluster_name    = aws_eks_cluster.EKSCluster.name
  node_group_name = "${var.env_prefix}-EKSCluster-NodeGroup"
  node_role_arn   = aws_iam_role.myAmazonEKSNodeRole.arn
  subnet_ids      = [
      aws_subnet.eks_vpc_PrivateSubnet02.id,
      aws_subnet.eks_vpc_PrivateSubnet01.id
    ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.Node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.Node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.Node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
