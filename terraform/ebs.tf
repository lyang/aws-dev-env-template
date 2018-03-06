resource "aws_ebs_volume" "seed" {
  availability_zone = "${var.availability-zone}"
  encrypted         = true
  size              = 1
  type              = "gp2"

  tags {
    ManagedBy = "${local.managed-by}"
  }
}

resource "aws_ebs_snapshot" "seed" {
  volume_id   = "${aws_ebs_volume.seed.id}"
  description = "Created by Terraform from aws_ebs_snapshot.seed"

  tags {
    ManagedBy = "${local.managed-by}"
    Baseline  = "True"
  }
}

resource "aws_ebs_volume" "current" {
  availability_zone = "${var.availability-zone}"
  snapshot_id       = "${data.aws_ebs_snapshot.latest.id}"
  size              = "${local.ebs-size}"
  type              = "${var.ebs-type}"

  tags {
    ManagedBy = "${local.managed-by}"
  }
}

resource "aws_volume_attachment" "current_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.current.id}"
  instance_id = "${aws_instance.dev.id}"

  provisioner "remote-exec" {
    when = "destroy"

    connection {
      type        = "ssh"
      host        = "${data.terraform_remote_state.self.public_dns}"
      user        = "${var.system-user}"
      private_key = "${tls_private_key.system-user.private_key_pem}"
    }

    inline = [
      "sudo umount -fd ${self.device_name} || sudo shutdown -r now",
    ]
  }
}
