output "public_ip" {
  value = "${aws_instance.dev.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.dev.public_dns}"
}
