# AWS DEV ENV

Using [Terraform]() and [Ansible]() to automate a development environment in AWS.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

* [AWS Account](https://aws.amazon.com/console/)
* [Terraform](https://www.terraform.io/)
* [Ansible](https://www.ansible.com/)

### Clone this repo
```
git clone https://github.com/lyang/aws-dev-env.git
```

### Installing Dependencies

```
brew install awscli terraform ansible
```

### Configuration AWS

```
aws configure
```

### Configuration Terraform backend
The following will prompt for the s3 backend configurations

```
cd aws-dev-env/terraform && terraform init
```
Personally I would rather use a config file like:

```
bucket         = "<your-s3-bucket>"
key            = "terraform.tfstate"
encrypt        = true
region         = "us-west-2"
```

And then you can run:
```
terraform init --backend-config=path/to/your/config-file
```

## Let's try it

```
terraform plan
```

You should see the terraform execution plan for creating AWS and local resouces.

What will be created?

* A `t2.micro` instance created from latest official debian AMI.
* A `10G` `gp2` EBS volume attached that instance.
* `CloudWatch` + `Lambda` function to take a snapshot of the EBS every `Monday 9am UTC`, which also drops snapshots older than 30 days.
* Various other supporting AWS resources like IAM roles/poicies etc.
* RSA key pairs stored in terraform s3 backend and locally, used to ssh into the instance later.
* Local artifacts generated to feed into `Ansible` in later steps.

## Go ahead and try to create your EC2 instance

```
terraform apply
```

If the plan looks right, go ahead.

## Provision the new instance

```
cd ../ansible && ansible-playbook bootstrap.yml provision.yml
```

* This will insert a piece of ssh config in `~/.ssh/config` so that you can `ssh dev` into your EC2 afterwards
* The additonal ebs volume will be mounted on /ebs/home
* A `admin` user will be created, with home dir on the ebs volume instead of root volume, with authorized_keys configured.
* Some packages will be installed, including TigerVNC server

After the ansible finishes provisioning the EC2, try
```
ssh dev
```
You should be able to get into the EC2 instance without password, and can sudo on the instance without password too.
If you have VNC client installed on your host machine, you should be able to connect to `localhost:5901` to see the remote desktop (requires an active ssh connection)

## Hack away

Go wild!

## Authors

* **Lin Yang**

## License

MIT
