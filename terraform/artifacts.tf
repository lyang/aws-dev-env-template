resource "local_file" "system-user-pem" {
  content  = "${tls_private_key.system-user.private_key_pem}"
  filename = "${substr("${path.module}/../generated/ssh-keys/${var.system-user}.pem", length(path.cwd)+1, -1)}"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${local.ssh-key-dir} && cp ${self.filename} ${local.ssh-key-dir}"
  }
}

resource "local_file" "primary-user-pem" {
  content  = "${tls_private_key.primary-user.private_key_pem}"
  filename = "${substr("${path.module}/../generated/ssh-keys/${var.primary-user}.pem", length(path.cwd)+1, -1)}"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${local.ssh-key-dir} && cp ${self.filename} ${local.ssh-key-dir}"
  }
}

resource "local_file" "primary-user-public-key" {
  content  = "${tls_private_key.primary-user.public_key_openssh}"
  filename = "${substr("${path.module}/../generated/ssh-keys/${var.primary-user}.pub", length(path.cwd)+1, -1)}"

  provisioner "local-exec" {
    command = "mkdir -p ${local.ssh-key-dir} && cp ${self.filename} ${local.ssh-key-dir}"
  }
}

resource "template_dir" "inventory" {
  source_dir      = "${path.module}/templates/inventory"
  destination_dir = "${substr("${path.module}/../generated/inventory", length(path.cwd)+1, -1)}"

  vars {
    device-name              = "${local.ebs-device-name}"
    ebs-snapshot-tag         = "${local.ebs-snapshot-tag}"
    host                     = "${aws_instance.dev.public_dns}"
    primary-user             = "${var.primary-user}"
    primary-user-private-key = "${basename(local_file.primary-user-pem.filename)}"
    primary-user-public-key  = "${basename(local_file.primary-user-public-key.filename)}"
    system-user              = "${var.system-user}"
    system-user-private-key  = "${basename(local_file.system-user-pem.filename)}"
    ssh-key-dir              = "${local.ssh-key-dir}"
  }
}
