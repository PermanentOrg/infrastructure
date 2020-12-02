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

resource "aws_instance" "api" {
  ami                    = module.amis.backend_ami_id
  instance_type          = "m4.large"
  vpc_security_group_ids = [module.amis.perm_env_sg_id]
  monitoring             = true
  private_ip             = "172.31.0.80"
  tags = {
    Name = "${vars.perm_env.name} backend"
  }
}

resource "aws_instance" "taskrunner" {
  ami                    = module.amis.taskrunner_ami_id
  instance_type          = "c4.xlarge"
  vpc_security_group_ids = [module.amis.perm_env_sg_id]
  monitoring             = true
  tags = {
    Name = "${vars.perm_env.name} taskrunner"
  }
}

resource "aws_instance" "cron" {
  ami                    = module.amis.cron_ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.amis.perm_env_sg_id]
  monitoring             = true
  tags = {
    Name = "${vars.perm_env.name} cron"
  }
}

module "amis" {
  source = "../modules/get-amis"
  perm_env = vars.perm_env
}
