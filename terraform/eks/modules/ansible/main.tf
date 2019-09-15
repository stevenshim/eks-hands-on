resource "null_resource" "init_eks" {
    triggers = {
        template = data.template_file.init_eks_sh.rendered
    }

    provisioner "local-exec" {
        command = "echo \"${data.template_file.init_eks_sh.rendered}\" > ${var.ansible_path}/ansible_helper.sh"
    }
}