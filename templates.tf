data "aws_availability_zones" "all" {}

data "template_file" "scylla_cidr" {
  template = "$${cidr}"

  vars = {
    cidr = "${var.cluster_broadcast == "private" ? element(aws_instance.scylla.*.private_ip, count.index) : element(aws_eip.scylla.*.public_ip, count.index)}/32"
  }

  count = var.cluster_count
}
