output "cluster_id" {
  value = random_uuid.cluster_id.result
}

output "seeds" {
  value = aws_eip.scylla.*.public_ip
}

output "private_key" {
  value = local.private_key
}

output "public_key" {
  value = local.public_key
}
