data "aws_ami" "cron" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["cron-${var.perm_env.name}"]
  }
  owners = [var.perm_ami_owner]
}

data "aws_ami" "backend" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = [var.perm_env.name]
  }
  owners = [var.perm_ami_owner]
}

data "aws_ami" "taskrunner" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["taskrunner-${var.perm_env.name}"]
  }
  owners = [var.perm_ami_owner]
}

data "aws_ami" "sftp" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["sftp-${var.perm_env.name}"]
  }
  owners = [var.perm_ami_owner]
}

data "aws_security_group" "default" {
  name = var.perm_env.sg
}

data "aws_subnet" "default" {
  availability_zone = var.perm_env.zone
}
