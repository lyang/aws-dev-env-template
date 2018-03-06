locals {
  ami-id                           = "${coalesce(var.ami-id, data.aws_ami.debian.id)}"
  ebs-size                         = "${max(data.aws_ebs_snapshot.latest.volume_size, var.ebs-size)}"
  ec2-snapshot-lambda-archive-path = "${substr("${path.module}/../generated/ebs-snapshot-lambda.py.zip", length(path.cwd)+1, -1)}"

  ec2-snapshot-lambda-arguments = {
    volume-id              = "${aws_ebs_volume.current.id}"
    managed-by             = "${local.managed-by}"
    ebs-snapshot-retention = "${var.ebs-snapshot-retention-days}"
  }

  managed-by = "${coalesce(var.managed-by, "Terraform")}"

  ssh-key-dir = "${dirname(var.ssh-key-dir)}"
}
