resource "aws_ebs_volume" "seed" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  encrypted         = true
  size              = 1
  type              = "gp2"
}

resource "aws_ebs_snapshot" "seed" {
  volume_id = "${aws_ebs_volume.seed.id}"
  description = "Created by Terraform aws_ebs_snapshot.seed"

  tags {
    Name = "${local.ebs-snapshot-tag}"
  }
}
