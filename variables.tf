variable "aws_access_key" {
  description = ""
  default     = ""
}

variable "aws_secret_key" {
  description = ""
  default     = ""
}

variable "aws_region" {
  description = ""
  default     = "eu-north-1"
}

variable "aws_instance_type" {
  description = ""
  default     = "i3.2xlarge"
}

variable "cluster_count" {
  description = ""
  default     = 3
}

variable "cluster_user_cidr" {
  description = ""
  type        = list(string)
  default     = []
}

variable "cluster_broadcast" {
  description = ""
  default     = "public"
}

variable "environment" {
  description = ""
  default     = "development"
}

variable "module_version" {
  description = ""
  default     = "0.0.1"
}

variable "owner" {
  description = ""
  default     = "terraform"
}

variable "user_ports" {
  description = ""
  type        = list(number)
  default = [
    22,
    9042,
    9160
  ]
}

variable "node_ports" {
  description = ""
  type        = list(number)
  default = [
    7000,
    7001
  ]
}

variable "monitor_ports" {
  description = ""
  type        = list(number)
  default = [
    9100,
    9180
  ]
}

variable "aws_ami_monitor" {
  description = ""
  type        = map(string)
  default = {
    "eu-north-1" = "ami-5ee66f20" # Official CentOS Linux 7 x86_64 HVM EBS ENA 1901_01
  }
}

variable "cluster_scylla_version" {
  description = ""
  default     = "4.1.7"
}

# Scylla AMI tags: ScyllaToolsVersion, ScyllaPython3Version, ScyllaVersion, build-id,
# Scylla AMI tags: scylla-git-commit, build-tag, ScyllaMachineImageVersion, branch
variable "aws_ami_scylla" {
  description = ""
  type        = map(string)
  default = {
    "4.1.7_eu-north-1" = "ami-0b5ca2b42dd0b8738"
    "4.1.6_eu-north-1" = "ami-013da0bd17560082a"
  }
}

variable "want_monitor" {
  type = bool
  default = false
}

variable "scylla_args" {
  description = ""
  type = string
  default = "{\"start_scylla_on_first_boot\":false}"
}