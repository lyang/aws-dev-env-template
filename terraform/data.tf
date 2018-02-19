data "aws_ami" "debian" {
  most_recent = true
  owners      = ["379101102735"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-*"]
  }
}

data "aws_instance" "dev" {
  instance_id = "${aws_instance.dev.id}"
}

data "template_file" "dev-inventory" {
  template = "${file("${path.module}/templates/dev-inventory")}"

  vars = {
    host        = "${aws_instance.dev.public_dns}"
    private-key = "${local_file.aws-dev-env-pem.filename}"
    ebs         = "${lookup(data.aws_instance.dev.ebs_block_device[0], "device_name")}"
  }
}

data "aws_ebs_snapshot" "dev" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["${aws_ebs_snapshot.seed.tags["Name"]}"]
  }
}

data "aws_availability_zones" "available" {}
