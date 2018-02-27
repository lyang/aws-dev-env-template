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

resource "local_file" "inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "${substr("${path.module}/../generated/inventory/inventory.yml", length(path.cwd)+1, -1)}"
}

resource "local_file" "group-vars-pristine" {
  content    = "${data.template_file.group-vars-pristine.rendered}"
  filename   = "${substr("${path.module}/../generated/inventory/group_vars/pristine.yml", length(path.cwd)+1, -1)}"
}

resource "local_file" "group-vars-managed" {
  content    = "${data.template_file.group-vars-managed.rendered}"
  filename   = "${substr("${path.module}/../generated/inventory/group_vars/managed.yml", length(path.cwd)+1, -1)}"
}
