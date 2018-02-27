locals {
  ami-id                           = "${coalesce(var.ami-id, data.aws_ami.debian.id)}"
  ebs-size                         = "${max(data.aws_ebs_snapshot.dev.volume_size, var.ebs-size)}"
  ebs-device-name                  = "${lookup(data.aws_instance.dev.ebs_block_device[0], "device_name")}"
  ebs-snapshot-tag                 = "dev-ebs-snapshot"
  ec2-snapshot-lambda-archive-path = "${substr("${path.module}/../generated/ebs-snapshot-lambda.py.zip", length(path.cwd)+1, -1)}"

  ec2-snapshot-lambda-arguments = {
    volume-id              = "${data.aws_ebs_volume.ebs.id}"
    ebs-snapshot-tag       = "${local.ebs-snapshot-tag}"
    ebs-snapshot-retention = "${var.ebs-snapshot-retention-days}"
  }
}
