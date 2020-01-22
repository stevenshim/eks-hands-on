resource "null_resource" "init_eks" {
    triggers = {
        always_run = timestamp()
//        template = data.template_file.init_eks_sh.rendered
    }

    provisioner "local-exec" {
        command = "echo \"${data.template_file.init_eks_sh.rendered}\" > ${var.ansible_path}/ansible_helper.sh"
    }
}

resource "null_resource" "ansible_var_file" {
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        command = "echo \"${data.template_file.ansible_var_file.rendered}\" > ${var.ansible_path}/var-file.yml"
    }
}