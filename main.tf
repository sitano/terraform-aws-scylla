resource "tls_private_key" "scylla" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_instance" "scylla" {
  ami               = local.scylla_ami
  instance_type     = var.aws_instance_type
  key_name          = aws_key_pair.support.key_name
  monitoring        = true
  availability_zone = element(local.aws_az, count.index % length(local.aws_az))
  subnet_id         = element(aws_subnet.subnet.*.id, count.index)
  user_data         = var.scylla_args

  security_groups = [
    aws_security_group.cluster.id,
    aws_security_group.cluster_user.id
  ]

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags  = merge(local.aws_tags, map("type", "scylla"))
  count = var.cluster_count

  depends_on = [
    aws_security_group.cluster,
    aws_security_group.cluster_user
  ]
}

resource "null_resource" "scylla" {
  triggers = {
    cluster_instance_ids = join(",", aws_instance.scylla.*.id)
    elastic_ips          = join(",", aws_eip.scylla.*.public_ip)
  }

  connection {
    type        = "ssh"
    host        = element(aws_eip.scylla.*.public_ip, count.index)
    user        = "centos"
    private_key = local.private_key
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = []
  }

  count = var.cluster_count
}

resource "aws_key_pair" "support" {
  key_name   = "cluster-support-${random_uuid.cluster_id.result}"
  public_key = local.public_key
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = local.aws_tags
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = local.aws_tags
}

resource "aws_subnet" "subnet" {
  availability_zone       = element(local.aws_az, count.index % length(local.aws_az))
  cidr_block              = format("10.0.%d.0/24", count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = local.aws_tags

  count      = var.cluster_count
  depends_on = [aws_internet_gateway.vpc_igw]
}

resource "aws_eip" "scylla" {
  vpc      = true
  instance = element(aws_instance.scylla.*.id, count.index)

  tags = merge(local.aws_tags, map("type", "scylla"))

  count      = var.cluster_count
  depends_on = [aws_internet_gateway.vpc_igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = local.aws_tags
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)

  count = var.cluster_count
}

resource "aws_security_group" "cluster" {
  name        = "cluster-${random_uuid.cluster_id.result}"
  description = "Security Group for inner cluster connections"
  vpc_id      = aws_vpc.vpc.id

  tags = local.aws_tags
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
}

resource "aws_security_group_rule" "cluster_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks = data.template_file.scylla_cidr.*.rendered

  from_port = element(var.node_ports, count.index)
  to_port   = element(var.node_ports, count.index)
  protocol  = "tcp"

  count = length(var.node_ports)
}

resource "aws_security_group_rule" "cluster_ingress_sg" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = element(var.node_ports, count.index)
  to_port                  = element(var.node_ports, count.index)
  protocol                 = "tcp"

  count = length(var.node_ports)
}

resource "aws_security_group" "cluster_user" {
  name        = "cluster-user-${random_uuid.cluster_id.result}"
  description = "Security Group for the user of cluster #${random_uuid.cluster_id.result}"
  vpc_id      = aws_vpc.vpc.id

  tags = local.aws_tags
}

resource "aws_security_group_rule" "cluster_user_egress" {
  type              = "egress"
  security_group_id = aws_security_group.cluster_user.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "cluster_user_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.cluster_user.id
  cidr_blocks       = compact(concat(var.cluster_user_cidr))
  from_port         = element(var.user_ports, count.index)
  to_port           = element(var.user_ports, count.index)
  protocol          = "tcp"

  count = length(var.user_ports)
}
