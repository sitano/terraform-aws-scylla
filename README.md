# terraform-aws-scylla

Terraform module for building ScyllaDB cluster infrastructure on AWS.

# Usage

Define variables in `.vars`:

    aws_access_key = ""
    aws_secret_key = ""
    aws_region = "eu-north-1"
    owner = ""
    cluster_user_cidr = ["/32"]

Execute:

    $ terraform apply -var-file=.vars

Destroy:  
  
    $ terraform destroy
