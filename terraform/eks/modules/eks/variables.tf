// variables from parent
variable "vpc_id" {}
variable "vpc_public_subnet_ids" {}
variable "vpc_private_subnet_ids" {}
variable "project_name" {}
variable "eks_version" {}
variable "kubectl_ec2_keypair" {}
variable "vpc_cidr_block" {}
variable "aws_krug_admin_role" {}
variable "eks_cluster_name" {}

// From here,
// variables with default value.
variable "kubectl_image_id" {
  default = "ami-0fd02cb7da42ee5e0"
  description = "Ubuntu Server 18.04 LTS"
}

variable "eks_worker_node_role_name" {
  default = "eks_worker_nodes_role"
}

variable "eks_worker_node_volume_size" {
  default = "10"
  description = "Gb"
}

variable "eks_worker_node_ec2_type" {
  default = "t3.small"
}

variable "eks_worker_nodes_asg_group" {
  default = {
    min = 2
    max = 2
    desire = 2
  }
}