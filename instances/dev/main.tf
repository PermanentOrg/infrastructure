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
    name = "dev"
    sg   = "Development"
    zone = "us-west-2c"
  }
}

resource "aws_instance" "api" {
  ami                    = module.perm_env_data.backend_ami
  instance_type          = "m4.xlarge"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  private_ip             = "172.31.0.80"
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} backend"
    type = "${var.perm_env.name} backend"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_outage_alarm" {
  alarm_name          = "${var.perm_env.name}-api-instance-outage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  ok_actions          = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  dimensions = {
    InstanceId = aws_instance.api.id
  }
}

resource "aws_instance" "taskrunner" {
  ami                    = module.perm_env_data.taskrunner_ami
  instance_type          = "c4.large"
  count                  = 1
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} taskrunner ${count.index}"
    type = "${var.perm_env.name} taskrunner"
  }
}

resource "aws_cloudwatch_metric_alarm" "taskrunner_outage_alarm" {
  alarm_name          = "${var.perm_env.name}-taskrunner-instance-outage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  ok_actions          = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  dimensions = {
    InstanceId = aws_instance.taskrunner[0].id
  }
}

resource "aws_instance" "cron" {
  ami                    = module.perm_env_data.cron_ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} cron"
    type = "${var.perm_env.name} cron"
  }
}

resource "aws_cloudwatch_metric_alarm" "cron_outage_alarm" {
  alarm_name          = "${var.perm_env.name}-cron-instance-outage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  ok_actions          = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  dimensions = {
    InstanceId = aws_instance.cron.id
  }
}

resource "aws_instance" "sftp" {
  ami                    = module.perm_env_data.sftp_ami
  instance_type          = "c4.large"
  vpc_security_group_ids = [module.perm_env_data.security_group]
  monitoring             = true
  private_ip             = "172.31.8.191"
  subnet_id              = module.perm_env_data.subnet
  tags = {
    Name = "${var.perm_env.name} sftp"
    type = "${var.perm_env.name} sftp"
  }
}

resource "aws_cloudwatch_metric_alarm" "sftp_outage_alarm" {
  alarm_name          = "${var.perm_env.name}-sftp-instance-outage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  ok_actions          = ["arn:aws:sns:us-west-2:364159549467:ec2-outage-notifications"]
  dimensions = {
    InstanceId = aws_instance.sftp.id
  }
}

module "perm_env_data" {
  source   = "../modules/get-data"
  perm_env = var.perm_env
}
