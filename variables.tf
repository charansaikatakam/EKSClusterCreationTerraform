variable "eks_vpc_cidr_block" {
  type = string
  default = "192.168.0.0/16"
  description = "Please provide the eks vpc CIDR Range"
}
variable "eks_vpc_PublicSubnet01_cidr_block" {
  type = string
  default = "192.168.0.0/18"
  description = "Please provide the eks public CIDR Range"
}
variable "eks_vpc_PublicSubnet02_cidr_block" {
  type = string
  default = "192.168.64.0/18"
  description = "Please provide the eks public CIDR Range"
}
variable "eks_vpc_PrivateSubnet01_cidr_block" {
  type = string
  default = "192.168.128.0/18"
  description = "Please provide the eks Private Subnet CIDR Range"
}
variable "eks_vpc_PrivateSubnet02_cidr_block" {
  type = string
  default = "192.168.192.0/18"
  description = "Please provide the eks Private Subnet CIDR Range"
}
variable "EKSClusterVersion" {
  type = string
  default = "1.31"
  description = "Please provide the eks cluster version"
}

variable "env_prefix" {
  type = string
  default = "dev"
  description = "Please provide the environment prefix"
}