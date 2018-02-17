resource "aws_key_pair" "dev" {
  key_name   = "lyang-imac"
  public_key = "${file("${path.module}/resources/id_rsa.pub")}"
}
