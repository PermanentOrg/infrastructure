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
  workspaces {
    name = "staging"
  }
}

data "aws_alb" "staging_lb" {
  name = "new staging"
}

resource "aws_launch_configuration" "staging_backend_lc" {
  name_prefix       = "staging-backend-"
  image_id          = data.aws_ami.backend_ami.id
  instance_type     = "m4.large"
  security_groups   = [data.aws_security_group.perm_sg.id]
  enable_monitoring = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "staging_taskrunner_lc" {
  name_prefix       = "staging-taskrunner-"
  image_id          = data.aws_ami.taskrunner_ami.id
  instance_type     = "c4.xlarge"
  security_groups   = [data.aws_security_group.perm_sg.id]
  enable_monitoring = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "cron" {
  ami                    = data.aws_ami.cron_ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.perm_sg.id]
  monitoring             = true
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
