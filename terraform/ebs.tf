resource "aws_ebs_volume" "seed" {
  availability_zone = "${random_shuffle.availability_zone.result[0]}"
  encrypted         = true
  size              = 1
  type              = "gp2"

  tags {
    Name = "${local.ebs-snapshot-tag}"
    Seed = "True"
  }
}

resource "aws_ebs_snapshot" "seed" {
  volume_id   = "${aws_ebs_volume.seed.id}"
  description = "Created by Terraform from aws_ebs_snapshot.seed"

  tags {
    Name = "${local.ebs-snapshot-tag}"
    Seed = "True"
  }
}

resource "random_shuffle" "availability_zone" {
  input        = ["${split(",", join(",", data.aws_availability_zones.available.names))}"]
  result_count = 1
}
