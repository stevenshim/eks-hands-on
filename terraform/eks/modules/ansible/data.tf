data "template_file" "init_eks_sh" {
  template = file("${path.module}/ansible_helper.sh.tpl")

  vars = {
    target_ec2_ip             =   var.kubectl_ec2_private_ip
    eks_cluster_name          =   var.eks_cluster_name
    eks_worker_role_arn       =   var.eks_worker_role_arn
  }
}