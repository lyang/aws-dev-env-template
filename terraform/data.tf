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

  snapshot_ids = ["${coalescelist(data.aws_ebs_snapshot_ids.dev.ids, list(aws_ebs_snapshot.seed.id))}"]

  filter {
    name   = "tag:Name"
    values = ["${local.ebs-snapshot-tag}"]
  }
}

data "aws_ebs_snapshot_ids" "dev" {
  owners = ["self"]

  filter {
    name   = "tag:Name"
    values = ["${local.ebs-snapshot-tag}"]
  }

  filter {
    name   = "tag:Seed"
    values = ["False"]
  }
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/templates/cloud-init.yml")}"

  vars = {
    system-user = "${var.system-user}"
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
    device-name             = "${local.ebs-device-name}"
    host                    = "${aws_instance.dev.public_dns}"
    primary-user            = "${var.primary-user}"
    primary-user-public-key = "${basename(local_file.primary-user-public-key.filename)}"
    system-user             = "${var.system-user}"
    system-user-private-key = "${basename(local_file.system-user-pem.filename)}"
    ssh-key-dir             = "${local.ssh-key-dir}"
  }
}

data "template_file" "group-vars-managed" {
  template = "${file("${path.module}/templates/inventory/group_vars/managed.yml")}"

  vars = {
    host                     = "${aws_instance.dev.public_dns}"
    primary-user             = "${var.primary-user}"
    primary-user-private-key = "${basename(local_file.primary-user-pem.filename)}"
    ssh-key-dir              = "${local.ssh-key-dir}"
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

data "aws_iam_policy_document" "assume-ec2-role-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dev-policy-document" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
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
  output_path = "${substr("${path.module}/../generated/ebs-snapshot-lambda.py.zip", length(path.cwd)+1, -1)}"
}
