resource "aws_iam_role" "eks_alb_ingress_controller_role" {
  name = var.eks_alb_ingress_controller_role_name
  assume_role_policy = data.template_file.eks_alb_ingress_controller_trust_relationship.rendered
}

resource "aws_iam_role_policy" "eks_alb_ingress_controller_policy" {
  name = "eks_alb_ingress_controller_role"
  role = aws_iam_role.eks_alb_ingress_controller_role.id
  policy = file("${path.module}/templates/eks_alb_controll_role_policy.json")
}

data "template_file" "eks_alb_ingress_controller_trust_relationship" {
  template = file("${path.module}/templates/eks_alb_controller_role_trust_relation.json.tpl")

  vars = {
    aws_iam_openid_connect_provider_arn = aws_iam_openid_connect_provider.oidc_iam_provider.arn
    aws_iam_openid_connect_provider_url = aws_iam_openid_connect_provider.oidc_iam_provider.url
    alb_ingress_controller_namespace = var.alb_ingress_controller_namespace
  }
}

