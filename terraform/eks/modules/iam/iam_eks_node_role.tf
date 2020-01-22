
resource "aws_iam_role" "eks_worker_node_role" {
  name = var.eks_worker_node_role_name
  assume_role_policy = file("${path.module}/templates/common_ec2_assume_role_policy.json")
}

resource "aws_iam_instance_profile" "eks_worker_node_instance_profile" {
  name = var.eks_worker_node_role_name
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_AutoScalingFullAccess" {
  policy_arn          =   "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role                =   aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_worker_node_role.name
}
