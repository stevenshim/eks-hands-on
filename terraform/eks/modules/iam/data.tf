data "aws_caller_identity" "current" {}

data "template_file" "admin_iam_role_policy" {
  template = file("${path.module}/ec2_aws_krug_amdin_role_policy.json")

  vars = {
    account_id = data.aws_caller_identity.current.account_id
    iam_user = var.iam_user_name
    admin_role_name = var.aws_krug_role
  }
}