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

  connection {
    type        = "ssh"
    host        = "${self.public_dns}"
    user        = "${var.system-user}"
    private_key = "${tls_private_key.system-user.private_key_pem}"
  }

  provisioner "file" {
    content     = "${data.template_file.ebs-backup-script.rendered}"
    destination = "${local.backup-script-path}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x ${local.backup-script-path}",
      "sudo mv ${local.backup-script-path} /usr/local/bin/${basename(local.backup-script-path)}",
    ]
  }
}
