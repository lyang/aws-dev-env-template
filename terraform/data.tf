data "aws_availability_zones" "available" {}

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

data "aws_ebs_snapshot" "dev" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["${aws_ebs_snapshot.seed.tags["Name"]}"]
  }
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/templates/cloud-init.yml.tpl")}"

  vars = {
    ec2-user = "${local.ec2-user}"
  }
}

data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory/inventory.yml.tpl")}"

  vars = {
    host = "${aws_instance.dev.public_dns}"
  }
}

data "template_file" "group-vars-pristine" {
  template = "${file("${path.module}/templates/inventory/group_vars/pristine.yml.tpl")}"

  vars = {
    ec2-user-private-key = "${local_file.ec2-user-pem.filename}"
    admin-public-key     = "${local_file.admin-pub.filename}"
    device-name          = "${lookup(data.aws_instance.dev.ebs_block_device[0], "device_name")}"
    ec2-user             = "${local.ec2-user}"
    host                 = "${aws_instance.dev.public_dns}"
  }
}

data "template_file" "group-vars-managed" {
  template = "${file("${path.module}/templates/inventory/group_vars/managed.yml.tpl")}"

  vars = {
    admin-private-key = "${local_file.admin-pem.filename}"
  }
}
