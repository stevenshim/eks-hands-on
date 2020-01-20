
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_private_node_group"
  node_role_arn = aws_iam_role.eks_worker_node_role.arn
  subnet_ids = var.vpc_private_subnet_ids
  instance_types = [var.eks_worker_node_ec2_type]
  disk_size = var.eks_worker_node_volume_size

  scaling_config {
    desired_size = lookup(var.eks_worker_nodes_asg_group, "desire")
    min_size = lookup(var.eks_worker_nodes_asg_group, "min")
    max_size = lookup(var.eks_worker_nodes_asg_group, "max")
  }

  remote_access {
    ec2_ssh_key = var.kubectl_ec2_keypair
    source_security_group_ids = [aws_security_group.eks_worker_nodes_sg.id]
  }

  labels = {
    node_kind = "eks_worker_nodes"
  }

  tags = {
    Name = "eks_worker_nodes"
    Managed_by = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_role_AmazonEC2ContainerRegistryReadOnly,
  ]

}