resource "local_file" "system-user-pem" {
  content  = "${tls_private_key.system-user.private_key_pem}"
  filename = "${path.module}/../generated/ssh-keys/${var.system-user}.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }
}

resource "local_file" "admin-pem" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "${path.module}/../generated/ssh-keys/admin.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${self.filename}"
  }
}

resource "local_file" "admin-pub" {
  content  = "${tls_private_key.admin.public_key_openssh}"
  filename = "${path.module}/../generated/ssh-keys/admin.pub"
}

resource "local_file" "inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "${path.module}/../generated/inventory/inventory.yml"
}

resource "local_file" "group-vars-pristine" {
  content  = "${data.template_file.group-vars-pristine.rendered}"
  filename = "${path.module}/../generated/inventory/group_vars/pristine.yml"
}

resource "local_file" "group-vars-managed" {
  content  = "${data.template_file.group-vars-managed.rendered}"
  filename = "${path.module}/../generated/inventory/group_vars/managed.yml"
}
