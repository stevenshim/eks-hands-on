resource "aws_iam_role" "aws_krug_admin" {
  name = var.aws_krug_role
  assume_role_policy = data.template_file.admin_iam_role_policy.rendered
}

resource "aws_iam_instance_profile" "aws_krug_admin_role_profile" {
  name = aws_iam_role.aws_krug_admin.name
  role = var.aws_krug_role
}

resource "aws_iam_role_policy_attachment" "aws_krug_admin_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.aws_krug_admin.name
}