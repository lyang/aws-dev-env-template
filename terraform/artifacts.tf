resource "local_file" "aws-dev-env-pem" {
  content  = "${tls_private_key.dev.private_key_pem}"
  filename = "../generated/aws-dev-env.pem"

  provisioner "local-exec" {
    command = "chmod 0400 ${self.filename}"
  }
}

resource "local_file" "dev-inventory" {
  content  = "${data.template_file.dev-inventory.rendered}"
  filename = "../generated/dev-inventory"
}
