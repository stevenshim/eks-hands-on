resource "aws_security_group" "kubectl_sg" {
  name = "${var.project_name}-kubectl-sg"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-kubectl-sg",
    Managed_by = "terraform"
  }
}

resource "aws_security_group_rule" "kubectl_sg_ingress_ssh" {
  description = "Allow SSH from MyIP"
  cidr_blocks = [
    "${data.external.myip.result["myip"]}/32"
  ]
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.kubectl_sg.id
  to_port = 22
  type = "ingress"
}

resource "aws_instance" "kubectl" {
  iam_instance_profile = var.aws_krug_admin_role
  associate_public_ip_address = true
  ami = var.kubectl_image_id
  subnet_id = var.vpc_public_subnet_ids[0]
  instance_type = "t3.micro"
  key_name = var.kubectl_ec2_keypair
  vpc_security_group_ids = [
    aws_security_group.kubectl_sg.id
  ]
  ebs_optimized = true

  tags = {
    Name = "${var.project_name}-kubectl"
    Managed_by = "terraform"
    Instance = "kubectl"
  }
}