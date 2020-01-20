//data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "oidc_iam_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  // AWS EKS ap-northeast-2 oidc(oidc.eks.ap-northeast-2.amazonaws.com) Root CA thumbprint.
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_iam_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [
        aws_iam_openid_connect_provider.oidc_iam_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_oidc_provier_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "aws_krug_eks_oidc_provier_role"
}