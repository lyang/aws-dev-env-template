provider "aws" {
  version = "~> 1.7"
}

terraform {
  backend "s3" {}
}

resource "aws_instance" "dev" {
  ami                    = "${local.ami-id}"
  iam_instance_profile   = "${aws_iam_instance_profile.dev.name}"
  instance_type          = "${var.instance-type}"
  key_name               = "${aws_key_pair.system-user.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet.id}"]

  user_data = "${data.template_file.cloud-init.rendered}"

  ebs_block_device {
    device_name = "/dev/xvdf"
    snapshot_id = "${data.aws_ebs_snapshot.dev.id}"
    volume_size = "${local.ebs-size}"
    volume_type = "${var.ebs-type}"
  }

  tags {
    Name = "dev"
  }

  connection {
    host        = "${self.public_dns}"
    type        = "ssh"
    agent       = false
    user        = "${var.system-user}"
    private_key = "${tls_private_key.system-user.private_key_pem}"
  }

  provisioner "file" {
    when        = "destroy"
    source      = "${path.module}/files/take-snapshot-before-destroy.sh"
    destination = "/tmp/take-snapshot-before-destroy.sh"
  }

  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "chmod +x /tmp/take-snapshot-before-destroy.sh",
      "/tmp/take-snapshot-before-destroy.sh ${data.aws_ebs_snapshot.dev.id} ${local.ebs-snapshot-tag}",
    ]
  }
}
