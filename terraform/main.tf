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

resource "aws_instance" "dev" {
  ami                    = "${data.aws_ami.debian.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.dev.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet.id}"]

  tags {
    Name = "dev"
  }
}

resource "local_file" "dev-host" {
  content  = "${data.template_file.dev-host.rendered}"
  filename = "${path.module}/../dev-host"
}
