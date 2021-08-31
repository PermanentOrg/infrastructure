terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "remote" {
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
    zone = string
  })
  default = {
    name = "staging"
    sg   = "Staging"
    zone = "us-west-2a"
  }
}


resource "aws_instance" "api" {
  ami                    = module.perm_env_data.backend_ami
  instance_type          = "m4.large"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  subnet_id              = module.perm_env_data.subnet
  private_ip             = "172.31.21.191"
  tags = {
    Name = "${var.perm_env.name} backend"
  }
}

resource "aws_instance" "taskrunner" {
  ami                    = module.perm_env_data.taskrunner_ami
  instance_type          = "c4.xlarge"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} taskrunner"
  }
}

resource "aws_instance" "cron" {
  ami                    = module.perm_env_data.cron_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} cron"
  }
}

module "perm_env_data" {
  source   = "../modules/get-data"
  perm_env = var.perm_env
}
