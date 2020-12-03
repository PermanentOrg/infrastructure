terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend remote {
    hostname     = "app.terraform.io"
    organization = "PermanentOrg"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

variable "perm_env" {
  description = "Permanent environment keywords"
  type = object({
    name = string
    sg   = string
  })
  default = {
    name = "staging"
    sg   = "Staging"
  }
}

variable "subnet_ids" {
  description = "The subnet to bring up all of the instances in."
  type        = list
  default     = ["subnet-a3f202fa", "subnet-0fc91a78"]
}

data "aws_lb_target_group" "webapp" {
  name = var.perm_env.name
}

data "aws_lb_target_group" "uploader" {
  name = "${var.perm_env.name}-uploader"
}

resource "aws_instance" "cron" {
  ami                    = module.amis.cron_ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.amis.perm_env_sg_id]
  monitoring             = true
  subnet_id              = var.subnet_ids[0]
  tags = {
    Name = "${var.perm_env.name} cron"
  }
}

resource "aws_launch_configuration" "backend_lc" {
  name_prefix       = "${var.perm_env.name}-backend-"
  image_id          = module.amis.backend_ami_id
  instance_type     = "m4.large"
  security_groups   = [module.amis.perm_env_sg_id]
  enable_monitoring = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "taskrunner_lc" {
  name_prefix       = "${var.perm_env.name}-taskrunner-"
  image_id          = module.amis.taskrunner_ami_id
  instance_type     = "c4.xlarge"
  security_groups   = [module.amis.perm_env_sg_id]
  enable_monitoring = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "taskrunner_as" {
  name                 = "${var.perm_env.name}-taskrunner-2.0"
  launch_configuration = aws_launch_configuration.taskrunner_lc.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend_as" {
  name                 = "${var.perm_env.name}-backend-2.0"
  launch_configuration = aws_launch_configuration.backend_lc.name
  min_size             = 1
  max_size             = 2
  target_group_arns    = [data.aws_lb_target_group.webapp, data.aws_lb_target_group.uploader]

  lifecycle {
    create_before_destroy = true
  }
}

module "amis" {
  source   = "../modules/get-amis"
  perm_env = var.perm_env
}
