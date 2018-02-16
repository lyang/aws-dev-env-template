provider "aws" {
  version = "~> 1.7"
  region  = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "969834822063-aws-dev-env"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "dev-env-terraform-state-locks"
  }
}

resource "aws_key_pair" "dev" {
  key_name   = "lyang-imac"
  public_key = "${file("${path.module}/resources/id_rsa.pub")}"
}

resource "aws_security_group" "ssh" {
  name = "ssh"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh"
  }
}

resource "aws_instance" "dev" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.dev.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]

  tags {
    Name = "dev"
  }
}
