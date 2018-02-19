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

data "template_file" "dev-inventory" {
  template = "${file("${path.module}/templates/dev-inventory")}"

  vars = {
    host        = "${aws_instance.dev.public_dns}"
    private-key = "${local_file.aws-dev-env-pem.filename}"
  }
}
