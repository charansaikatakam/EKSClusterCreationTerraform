resource "aws_vpc" "eks_vpc" {
  cidr_block       = var.eks_vpc_cidr_block
  
  tags = {
    Name = "${var.env_prefix}-eksManaged-VPC"
  }
}

resource "aws_internet_gateway" "eks_vpc_gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.env_prefix}-eksManaged-VPC-IGW"
  }
}
data "aws_availability_zones" "available_AZ" {
  state = "available"
}
resource "aws_subnet" "eks_vpc_PublicSubnet01" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.eks_vpc_PublicSubnet01_cidr_block
  availability_zone = data.aws_availability_zones.available_AZ.names[1]

  tags = {
    Name = "${var.env_prefix}-PublicSubnet01"
	"kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "eks_vpc_PublicSubnet02" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.eks_vpc_PublicSubnet02_cidr_block
  availability_zone = data.aws_availability_zones.available_AZ.names[0]

  tags = {
    Name = "${var.env_prefix}-PublicSubnet02"
	"kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "eks_vpc_PrivateSubnet01" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.eks_vpc_PrivateSubnet01_cidr_block
  availability_zone = data.aws_availability_zones.available_AZ.names[0]

  tags = {
    Name = "${var.env_prefix}-PrivateSubnet01"
	"kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "eks_vpc_PrivateSubnet02" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.eks_vpc_PrivateSubnet02_cidr_block
  availability_zone = data.aws_availability_zones.available_AZ.names[1]

  tags = {
    Name = "${var.env_prefix}-PrivateSubnet02"
	"kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "eks_vpc_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  depends_on = [aws_internet_gateway.eks_vpc_gw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_gw.id
  }

  tags = {
    Name = "${var.env_prefix}-eks-Public-route-table"
	Network = "Public"
  }
}

resource "aws_route_table_association" "eks_vpc_public_route_assosciation_PublicSubnet01" {
  subnet_id      = aws_subnet.eks_vpc_PublicSubnet01.id
  route_table_id = aws_route_table.eks_vpc_public_route_table.id
}

resource "aws_route_table_association" "eks_vpc_public_route_assosciation_PublicSubnet02" {
  subnet_id      = aws_subnet.eks_vpc_PublicSubnet02.id
  route_table_id = aws_route_table.eks_vpc_public_route_table.id
}

resource "aws_eip" "natGW_eip" {
  domain   = "vpc"
  depends_on = [aws_internet_gateway.eks_vpc_gw]
}

resource "aws_nat_gateway" "eks_vpc_nat_gw" {
  allocation_id = aws_eip.natGW_eip.id
  depends_on = [aws_internet_gateway.eks_vpc_gw,aws_eip.natGW_eip,aws_subnet.eks_vpc_PublicSubnet01]
  subnet_id     = aws_subnet.eks_vpc_PublicSubnet01.id

  tags = {
    Name = "${var.env_prefix}-eks-nat-gw"
  }

}

resource "aws_route_table" "eks_vpc_private_route_table_PrivateSubnet" {
  vpc_id = aws_vpc.eks_vpc.id
  depends_on = [aws_internet_gateway.eks_vpc_gw,aws_nat_gateway.eks_vpc_nat_gw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks_vpc_nat_gw.id
  }

  tags = {
    Name = "${var.env_prefix}-eks-Private-route-table-01"
	Network = "Private"
  }
}

resource "aws_route_table_association" "eks_vpc_private_route_assosciation_PrivateSubnet01" {
  subnet_id      = aws_subnet.eks_vpc_PrivateSubnet01.id
  route_table_id = aws_route_table.eks_vpc_private_route_table_PrivateSubnet.id
}

resource "aws_route_table_association" "eks_vpc_private_route_assosciation_PrivateSubnet02" {
  subnet_id      = aws_subnet.eks_vpc_PrivateSubnet02.id
  route_table_id = aws_route_table.eks_vpc_private_route_table_PrivateSubnet.id
}

resource "aws_security_group" "ControlPlaneSecurityGroup" {
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.env_prefix}-ControlPlaneSecurityGroup"
  }
}