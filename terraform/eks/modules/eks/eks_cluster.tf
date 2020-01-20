resource "aws_security_group" "eks_cluster_sg" {
  name = "${var.project_name}-eks-control-plane-sg"
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
    Name = "${var.project_name}-eks-control-plane-sg",
    Managed_by = "terraform"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  description = "Allow HTTPS traffic from VPC networks"
  from_port = 443
  protocol = "tcp"
  cidr_blocks = [
    var.vpc_cidr_block
  ]
  to_port = 443
  type = "ingress"
}


resource "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
  role_arn = var.eks_cluster_role.arn
  version = var.eks_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = false

    # ISSUE : Not support new AZ(ap-northeast-2b) in Seoul region.
    subnet_ids = [
      var.vpc_private_subnet_ids[0],
      var.vpc_private_subnet_ids[1],
      var.vpc_private_subnet_ids[2]
    ]

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id
    ]
  }
}