variable "instance-type" {
  default = "t2.micro"
}

variable "ebs-snapshot-schedule" {
  default = "cron(0 9 ? * MON *)"
}

variable "ebs-snapshot-retention-days" {
  default = 30
}
