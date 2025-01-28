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
variable "vpc_CNI_addon_required" {
  type = bool
  default = false
  description = "Please whether vpc CNI addon is required or not"
}
variable "coreDNS_addon_required" {
  type = bool
  default = false
  description = "Please whether coreDNS addon is required or not"
}
variable "kubeProxy_addon_required" {
  type = bool
  default = false
  description = "Please whether kubeProxy addon is required or not"
}
variable "eks_pod_identity_agent_addon_required" {
  type = bool
  default = false
  description = "Please whether eks-pod-identity-agent addon is required or not"
}
variable "userName" {
  type = string
  default = "Terraformuser"
  description = "Please mention the user name to provide the EKS Admin access"
}