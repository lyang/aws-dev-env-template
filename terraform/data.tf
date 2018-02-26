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

data "aws_ebs_volume" "ebs" {
  most_recent = true

  filter {
    name   = "attachment.instance-id"
    values = ["${aws_instance.dev.id}"]
  }

  filter {
    name   = "attachment.device"
    values = ["${local.ebs-device-name}"]
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

data "template_file" "cloud-init" {
  template = "${file("${path.module}/templates/cloud-init.yml")}"

  vars = {
    ec2-user = "${local.ec2-user}"
  }
}

data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory/inventory.yml")}"

  vars = {
    host = "${aws_instance.dev.public_dns}"
  }
}

data "template_file" "group-vars-pristine" {
  template = "${file("${path.module}/templates/inventory/group_vars/pristine.yml")}"

  vars = {
    ec2-user-private-key = "${local_file.ec2-user-pem.filename}"
    admin-public-key     = "${local_file.admin-pub.filename}"
    device-name          = "${local.ebs-device-name}"
    ec2-user             = "${local.ec2-user}"
    host                 = "${aws_instance.dev.public_dns}"
  }
}

data "template_file" "group-vars-managed" {
  template = "${file("${path.module}/templates/inventory/group_vars/managed.yml")}"

  vars = {
    admin-private-key = "${local_file.admin-pem.filename}"
    host              = "${aws_instance.dev.public_dns}"
  }
}

data "aws_iam_policy_document" "assume-lambda-role-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2-snapshot-policy-document" {
  statement {
    actions = [
      "logs:*",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:DeleteSnapshot",
      "ec2:Describe*",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute",
    ]

    resources = ["*"]
  }
}

data "archive_file" "ec2-snapshot-lambda" {
  type        = "zip"
  source_file = "${path.module}/files/ebs-snapshot-lambda.py"
  output_path = "${local.ec2-snapshot-lambda-archive-path}"
}
