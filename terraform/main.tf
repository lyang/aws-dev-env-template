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
  key_name               = "${aws_key_pair.ec2-user.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet.id}"]

  user_data = "${data.template_file.cloud-init.rendered}"

  ebs_block_device {
    device_name = "/dev/xvdf"
    snapshot_id = "${data.aws_ebs_snapshot.dev.id}"
    volume_size = 10
    volume_type = "gp2"
  }

  tags {
    Name = "dev"
  }
}
