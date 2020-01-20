resource "aws_security_group" "eks_worker_nodes_sg" {
  name = "${var.project_name}-eks-worker-nodes-sg"
  vpc_id = var.vpc_id

  # Outbound ALL
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-eks-worker-nodes-sg",
    Managed_by = "terraform"
  }
}

resource "aws_security_group_rule" "eks_workder_node_ingress_tcp1" {
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description = "Allow 1025 to 65535 from EKS Control Plane"
  from_port = 1025
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.eks_worker_nodes_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "eks_workder_node_ingress_tcp2" {
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description = "Allow 443 from EKS Control Plane"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.eks_worker_nodes_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "eks_worker_node_kubectl_access" {
  source_security_group_id = aws_security_group.kubectl_sg.id
  description = "Allow SSH traffic from kubectl"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.eks_worker_nodes_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "eks_workder_node_ingress_between_nodes" {
  source_security_group_id = aws_security_group.eks_worker_nodes_sg.id
  description = "Allow all traffic from worker nodes each other"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.eks_worker_nodes_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "eks_workder_node_ingress_udp_protocol_between_nodes" {
  source_security_group_id = aws_security_group.eks_worker_nodes_sg.id
  description = "Allow UDP traffic from worker nodes each other"
  from_port = 53
  to_port = 53
  protocol = "udp"
  security_group_id = aws_security_group.eks_worker_nodes_sg.id
  type = "ingress"
}