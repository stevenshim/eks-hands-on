terraform {}

provider "template" {
  version = "~> 2.1"
}

provider "aws" {
  version = "~> 2.28"
  region = local.aws_region
}

provider "external" {
  version = "~> 1.2.0"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = local.vpc_name
  eks_cluster_name = local.eks_cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id = module.vpc.vpc_id
  vpc_public_subnet_ids = module.vpc.vpc_public_subnet_ids
  vpc_private_subnet_ids = module.vpc.vpc_private_subnet_ids
  vpc_cidr_block = module.vpc.vpc_cidr_block

  project_name = local.project_name
  kubectl_ec2_keypair = var.kubectl_ec2_keypair
  eks_version = var.eks_version

}