resource "aws_security_group" "ssh" {
  name = "ssh"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    ManagedBy = "${local.managed-by}"
  }
}

resource "aws_security_group" "internet" {
  name = "internet"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    ManagedBy = "${local.managed-by}"
  }
}
