resource "tls_private_key" "system-user" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "system-user" {
  key_name   = "system-user-key-generated-by-terraform"
  public_key = "${tls_private_key.system-user.public_key_openssh}"
}
