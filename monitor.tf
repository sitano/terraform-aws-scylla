resource "aws_instance" "monitor" {
  ami               = lookup(var.aws_ami_monitor, var.aws_region)
  instance_type     = "t3.medium"
  key_name          = aws_key_pair.support.key_name
  monitoring        = true
  availability_zone = element(local.aws_az, 0)
  subnet_id         = element(aws_subnet.subnet.*.id, 0)
  security_groups = [
    aws_security_group.cluster.id,
    aws_security_group.cluster_user.id
  ]

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = merge(local.aws_tags, map("type", "monitor"))

  depends_on = [
    aws_security_group.cluster,
    aws_security_group.cluster_user
  ]

  count = var.want_monitor ? 1 : 0
}

resource "aws_eip" "monitor" {
  vpc      = true
  instance = aws_instance.monitor[0].id

  tags = merge(local.aws_tags, map("type", "monitor"))

  depends_on = [aws_internet_gateway.vpc_igw]

  count = var.want_monitor ? 1 : 0
}

resource "aws_security_group_rule" "cluster_monitor" {
  type              = "ingress"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks = [
    "${aws_eip.monitor[0].public_ip}/32",
  ]
  from_port = element(var.monitor_ports, count.index)
  to_port   = element(var.monitor_ports, count.index)
  protocol  = "tcp"

  count = var.want_monitor ? length(var.monitor_ports) : 0
}

resource "aws_security_group_rule" "cluster_monitor_sg" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = element(var.monitor_ports, count.index)
  to_port                  = element(var.monitor_ports, count.index)
  protocol                 = "tcp"

  count = var.want_monitor ? length(var.monitor_ports) : 0
}

resource "aws_security_group_rule" "cluster_monitor_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks = [
    "${aws_eip.monitor[0].public_ip}/32",
  ]
  from_port = element(var.node_ports, count.index)
  to_port   = element(var.node_ports, count.index)
  protocol  = "tcp"

  count = var.want_monitor ? length(var.node_ports) : 0
}
