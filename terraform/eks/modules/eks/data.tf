data "external" "myip" {
 program = ["${path.module}/templates/myip.sh"]
}

data "template_file" "eks_worker_node_userdata" {
  template = file("${path.module}/templates/eks_worker_node_userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.eks_cluster.name
    endpoint             = aws_eks_cluster.eks_cluster.endpoint
    cluster_auth_base64  = aws_eks_cluster.eks_cluster.certificate_authority[0].data

    pre_userdata         = lookup(var.eks_worker_user_data_group, "pre_userdata")
    additional_userdata  = lookup(var.eks_worker_user_data_group, "additional_userdata")
    enable_docker_bridge = lookup(var.eks_worker_user_data_group, "enable_docker_bridge")
    kubelet_extra_args   = lookup(var.eks_worker_user_data_group, "kubelet_extra_args")
  }
}

