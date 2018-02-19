resource "tls_private_key" "dev" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "dev" {
  key_name   = "dev-key-generated-by-terraform"
  public_key = "${tls_private_key.dev.public_key_openssh}"
}
