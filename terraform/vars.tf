variable "region" {
  type = "string"
}

variable "availability-zone" {
  type = "string"
}

variable "managed-by" {
  default = ""
}

variable "ami-id" {
  default = ""
}

variable "instance-type" {
  default = "t2.micro"
}

variable "ebs-size" {
  default = 10
}

variable "ebs-type" {
  default = "gp2"
}

variable "ebs-snapshot-schedule" {
  default = "cron(0 9 ? * MON *)"
}

variable "ebs-snapshot-retention-days" {
  default = 30
}

variable "system-user" {
  default = "ec2-user"
}

variable "primary-user" {
  default = "admin"
}

variable "ssh-key-dir" {
  default = "~/.ssh/aws-dev-env/"
}
