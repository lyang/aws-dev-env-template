provider "aws" {
  version = "~> 1.7"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

resource "aws_instance" "dev" {
  ami                    = "${data.aws_ami.debian.id}"
  instance_type          = "${var.instance-type}"
  key_name               = "${aws_key_pair.dev.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet.id}"]

  tags {
    Name = "dev"
  }
}
