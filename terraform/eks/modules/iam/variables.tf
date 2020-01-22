variable "project_name" {}
variable "eks_cluster" {}


variable "eks_alb_ingress_controller_role_name" {
  default = "eks_alb_ingress_controller_role"
}

variable "alb_ingress_controller_namespace" {
  default = "kube-system"
}

variable "eks_worker_node_role_name" {
  default = "eks_worker_nodes_role"
}