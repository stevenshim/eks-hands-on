resource "aws_iam_role" "kubectl_role" {
  name = var.kubectl_ec2_role_name
  assume_role_policy = file("${path.module}/templates/common_ec2_assume_role_policy.json")
}

resource "aws_iam_instance_profile" "kubectl_role_profile" {
  name = aws_iam_role.kubectl_role.name
  role = var.kubectl_ec2_role_name
}

resource "aws_iam_role_policy_attachment" "kubectl_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.kubectl_role.name
}

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
  iam_instance_profile = aws_iam_instance_profile.kubectl_role_profile.name
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