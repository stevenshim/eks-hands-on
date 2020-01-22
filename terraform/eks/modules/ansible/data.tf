data "template_file" "init_eks_sh" {
  template = file("${path.module}/ansible_helper.sh.tpl")

  vars = {
    target_ec2_ip             =   var.kubectl_ec2_public_ip
    eks_cluster_name          =   var.eks_cluster_name
    eks_worker_role_arn       =   var.eks_worker_role_arn
  }
}

data "template_file" "ansible_var_file" {
  template = file("${path.module}/ansible_var_file.yml.tpl")

  vars = {
    target_ec2_ip             =   var.kubectl_ec2_public_ip
    eks_cluster_name          =   var.eks_cluster_name
    eks_worker_role_arn       =   var.eks_worker_role_arn
    ingress_role_arn          =   var.eks_alb_ingress_controller_role_arn
  }
}