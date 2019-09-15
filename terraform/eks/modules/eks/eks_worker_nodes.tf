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

resource "aws_iam_role" "eks_worker_node_role" {
  name = var.eks_worker_node_role_name
  assume_role_policy = file("${path.module}/templates/common_ec2_assume_role_policy.json")
}

resource "aws_iam_instance_profile" "eks_app_worker_node_profile" {
  name = var.eks_worker_node_role_name
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_app_worker_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_app_worker_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_app_worker_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_launch_configuration" "eks_worker_nodes_lc" {
  name_prefix = "${aws_eks_cluster.eks_cluster.name}_worker_node"
  associate_public_ip_address = var.eks_worker_node_public_ip
  security_groups = [
    aws_security_group.eks_worker_nodes_sg.id
  ]
  iam_instance_profile = aws_iam_instance_profile.eks_app_worker_node_profile.name
  image_id = var.eks_worker_node_ami_id
  instance_type = var.eks_worker_node_ec2_type
  key_name = var.kubectl_ec2_keypair
  user_data = data.template_file.eks_worker_node_userdata.rendered
  enable_monitoring = var.eks_worker_nodes_enable_monitoring

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = var.eks_worker_node_volume_size
    volume_type = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "eks_worker_nodes_asg" {
  launch_configuration = aws_launch_configuration.eks_worker_nodes_lc.id
  desired_capacity = lookup(var.eks_worker_nodes_asg_group, "desire")
  min_size = lookup(var.eks_worker_nodes_asg_group, "min")
  max_size = lookup(var.eks_worker_nodes_asg_group, "max")
  name = "${aws_eks_cluster.eks_cluster.name}-worker"
  vpc_zone_identifier = [
    var.vpc_private_subnet_ids[0],
    var.vpc_private_subnet_ids[1],
    var.vpc_private_subnet_ids[2]
  ]

  tag {
    key = "Name"
    value = "${aws_eks_cluster.eks_cluster.name}-worker"
    propagate_at_launch = true
  }

  tag {
    key = "Managed_by"
    value = "terraform"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}"
    value = "owned"
    propagate_at_launch = true
  }

  depends_on = [
    "aws_launch_configuration.eks_worker_nodes_lc"
  ]
}