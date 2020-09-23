provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

locals {
  aws_az = data.aws_availability_zones.all.names

  private_key  = tls_private_key.scylla.private_key_pem
  public_key   = tls_private_key.scylla.public_key_openssh
  cluster_name = "cluster-${random_uuid.cluster_id.result}"
  scylla_ami   = lookup(var.aws_ami_scylla, format("%s_%s", var.cluster_scylla_version, var.aws_region))

  aws_tags = {
    environment = var.environment
    version     = var.module_version
    cluster_id  = random_uuid.cluster_id.result
    owner       = var.owner
    Name        = "${var.owner}-${local.cluster_name}"
  }
}

resource "random_uuid" "cluster_id" {}
