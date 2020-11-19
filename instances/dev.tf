terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

data "aws_ami" "dev_cron" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["cron-dev"]
  }
  owners = ["364159549467"]
}

data "aws_ami" "dev_api" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["dev"]
  }
  owners = ["364159549467"]
}

data "aws_ami" "dev_taskrunner" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["taskrunner-dev"]
  }
  owners = ["364159549467"]
}

data "aws_security_group" "dev_sg" {
  name = "Development"
}

data "aws_security_group" "bitbucket_sg" {
  name = "Bitbucket Pipelines Inbound"
}

resource "aws_instance" "api" {
    ami = data.aws_ami.dev_api.id
    instance_type = "m4.large"
    vpc_security_group_ids = [data.aws_security_group.dev_sg.id, data.aws_security_group.bitbucket_sg.id]
    monitoring = true
    key_name = "PermRecord"
    private_ip = "172.31.0.80"
    tags = { 
        Name = "Dev Backend"
    }
}

resource "aws_instance" "taskrunner" {
    ami = data.aws_ami.dev_taskrunner.id
    instance_type = "c4.xlarge"
    vpc_security_group_ids = [data.aws_security_group.dev_sg.id, data.aws_security_group.bitbucket_sg.id]
    monitoring = true
    key_name = "PermRecord"
    private_ip = "172.31.0.79"
    tags = {
        Name = "Dev Taskrunner"
    }
}

resource "aws_instance" "cron" {
    ami = data.aws_ami.dev_cron.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [data.aws_security_group.dev_sg.id, data.aws_security_group.bitbucket_sg.id]
    monitoring = true
    key_name = "PermRecord"
    private_ip = "172.31.0.78"
    tags = {
        Name = "Dev Cron"
    }
}
