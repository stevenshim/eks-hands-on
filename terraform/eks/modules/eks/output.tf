output "kubectl_ec2_public_ip" {
  value = aws_instance.kubectl.public_ip
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster" {
  value = aws_eks_cluster.eks_cluster
}