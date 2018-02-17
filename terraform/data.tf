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

data "template_file" "dev-host" {
  template = "${file("${path.module}/resources/dev-host")}"

  vars = {
    host = "${aws_instance.dev.public_dns}"
  }
}
