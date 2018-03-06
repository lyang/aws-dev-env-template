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

data "external" "backend-config" {
  program = ["${path.module}/files/get-backend-config.sh", "${path.module}/.terraform/terraform.tfstate"]
}

data "terraform_remote_state" "self" {
  backend = "s3"

  config {
    bucket = "${data.external.backend-config.result["bucket"]}"
    key    = "${data.external.backend-config.result["key"]}"
    region = "${data.external.backend-config.result["region"]}"
  }
}

data "aws_ebs_snapshot" "latest" {
  most_recent = true
  owners      = ["self"]

  snapshot_ids = ["${coalescelist(data.aws_ebs_snapshot_ids.baseline.ids, list(aws_ebs_snapshot.seed.id))}"]
}

data "aws_ebs_snapshot_ids" "baseline" {
  owners = ["self"]

  filter {
    name   = "tag:ManagedBy"
    values = ["${local.managed-by}"]
  }

  filter {
    name   = "tag:Baseline"
    values = ["True"]
  }
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/templates/cloud-init.yml")}"

  vars = {
    system-user = "${var.system-user}"
  }
}

data "template_file" "ebs-backup-script" {
  template = "${file("${path.module}/templates/backup-ebs-volume")}"

  vars = {
    managed-by = "${local.managed-by}"
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
