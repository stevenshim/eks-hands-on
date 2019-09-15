output "kubectl_ec2_public_ip" {
  value = aws_instance.kubectl.public_ip
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_worker_role_arn" {
  value = aws_iam_role.eks_worker_node_role.arn
}