resource "tls_private_key" "ec2-user" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "ec2-user" {
  key_name   = "ec2-user-key-generated-by-terraform"
  public_key = "${tls_private_key.ec2-user.public_key_openssh}"
}
