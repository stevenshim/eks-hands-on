resource "aws_iam_role" "iam_service_account_sample_role" {
  name = "iam_service_account_sample_role"
  assume_role_policy = data.template_file.iam_service_account_sample_role_trust_relationship.rendered
}

resource "aws_iam_role_policy" "iam_service_account_sample_policy" {
  name = "iam_service_account_sample_role"
  role = aws_iam_role.iam_service_account_sample_role.id
  policy = file("${path.module}/templates/iam_service_account_sample_role_policy.json")
}

data "template_file" "iam_service_account_sample_role_trust_relationship" {
  template = file("${path.module}/templates/iam_service_account_sample_role_trust_relation.json.tpl")

  vars = {
    aws_iam_openid_connect_provider_arn = aws_iam_openid_connect_provider.oidc_iam_provider.arn
    aws_iam_openid_connect_provider_url = aws_iam_openid_connect_provider.oidc_iam_provider.url
    alb_ingress_controller_namespace = var.alb_ingress_controller_namespace
  }
}

