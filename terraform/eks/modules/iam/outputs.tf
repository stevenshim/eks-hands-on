output "admin_role_name" {
  value = aws_iam_role.aws_krug_admin.name
}

output "admin_role_id" {
  value = aws_iam_role.aws_krug_admin.id
}

output "admin_role_arn" {
  value = aws_iam_role.aws_krug_admin.arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}