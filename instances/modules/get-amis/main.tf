data "aws_ami" "cron_ami" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["cron-${var.perm_env.name}"]
  }
  owners = [var.perm_ami_owner]
}

data "aws_ami" "backend_ami" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = [var.perm_env.name]
  }
  owners = [var.perm_ami_owner]
}

data "aws_ami" "taskrunner_ami" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["taskrunner-${var.perm_env.name}"]
  }
  owners = [var.perm_ami_owner]
}

data "aws_security_group" "perm_sg" {
  name = var.perm_env.sg
}

