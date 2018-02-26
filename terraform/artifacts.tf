resource "local_file" "system-user-pem" {
  content  = "${tls_private_key.system-user.private_key_pem}"
  filename = "${substr("${path.module}/../generated/ssh-keys/${var.system-user}.pem", length(path.cwd)+1, -1)}"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }
}

resource "local_file" "admin-pem" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "${substr("${path.module}/../generated/ssh-keys/admin.pem", length(path.cwd)+1, -1)}"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }
}

resource "local_file" "admin-pub" {
  content  = "${tls_private_key.admin.public_key_openssh}"
  filename = "${substr("${path.module}/../generated/ssh-keys/admin.pub", length(path.cwd)+1, -1)}"
}

resource "local_file" "inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "${substr("${path.module}/../generated/inventory/inventory.yml", length(path.cwd)+1, -1)}"
}

resource "local_file" "group-vars-pristine" {
  content  = "${data.template_file.group-vars-pristine.rendered}"
  filename = "${substr("${path.module}/../generated/inventory/group_vars/pristine.yml", length(path.cwd)+1, -1)}"
}

resource "local_file" "group-vars-managed" {
  content  = "${data.template_file.group-vars-managed.rendered}"
  filename = "${substr("${path.module}/../generated/inventory/group_vars/managed.yml", length(path.cwd)+1, -1)}"
}
