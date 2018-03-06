provider "aws" {
  version = "~> 1.7"
  region  = "${var.region}"
}

terraform {
  backend "s3" {}
}

resource "aws_instance" "dev" {
  ami                    = "${local.ami-id}"
  availability_zone      = "${var.availability-zone}"
  iam_instance_profile   = "${aws_iam_instance_profile.dev.name}"
  instance_type          = "${var.instance-type}"
  key_name               = "${aws_key_pair.system-user.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet.id}"]

  user_data = "${data.template_file.cloud-init.rendered}"

  tags {
    ManagedBy = "${local.managed-by}"
  }
}
