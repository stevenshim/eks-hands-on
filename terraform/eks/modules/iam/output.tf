output "eks_cluster_role" {
  value = aws_iam_role.eks_cluster_role
}

output "eks_worker_node_role" {
  value = aws_iam_role.eks_worker_node_role
}

output "eks_alb_ingress_controller_role_arn" {
  value = aws_iam_role.eks_alb_ingress_controller_role.arn
}