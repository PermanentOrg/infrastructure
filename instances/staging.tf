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

data "aws_ami" "staging_cron" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["cron-staging"]
  }
  owners = ["364159549467"]
}

data "aws_ami" "staging_api" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["staging"]
  }
  owners = ["364159549467"]
}

data "aws_ami" "staging_taskrunner" {
  most_recent = true

  filter {
    name = "tag:Name"
    values = ["taskrunner-staging"]
  }
  owners = ["364159549467"]
}

data "aws_security_group" "staging_sg" {
  name = "Staging"
}

data "aws_elb" "staging_lb" {
  name = "staging"
}

resource "aws_launch_configuration" "staging_backend_lc" {
    name_prefix = "staging-backend-"
    image_id = data.aws_ami.staging_api.id
    instance_type = "m4.large"
    security_groups = [data.aws_security_group.staging_sg.id]
    enable_monitoring = true
    key_name = "PermRecord"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "staging_taskrunner_lc" {
    name_prefix = "staging-taskrunner-"
    image_id = data.aws_ami.staging_taskrunner.id
    instance_type = "c4.xlarge"
    security_groups = [data.aws_security_group.staging_sg.id]
    enable_monitoring = true
    key_name = "PermRecord"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_instance" "cron" {
    ami = data.aws_ami.staging_cron.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [data.aws_security_group.staging_sg.id]
    monitoring = true
    key_name = "PermRecord"
    tags = {
        Name = "staging cron"
    }
}

resource "aws_autoscaling_group" "staging_taskrunner_as" {
  name                 = "staging taskrunner"
  launch_configuration = aws_launch_configuration.staging_taskrunner_lc.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "staging_backend_as" {
  name                 = "staging backend"
  launch_configuration = aws_launch_configuration.staging_backend_lc.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}
