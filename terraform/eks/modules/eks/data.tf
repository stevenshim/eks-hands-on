data "external" "myip" {
 program = ["${path.module}/templates/myip.sh"]
}
