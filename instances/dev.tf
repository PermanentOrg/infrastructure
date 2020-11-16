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

data "aws_ami" "dev_api" {
  most_recent = true

  filter {
    name = "tag:environment"
    values = ["dev"]
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
