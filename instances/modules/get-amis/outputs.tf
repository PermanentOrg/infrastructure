output "backend_ami_id" {
  value = data.aws_ami.backend_ami.id
}

output "cron_ami_id" {
  value = data.aws_ami.cron_ami.id
}

output "taskrunner_ami_id" {
  value = data.aws_ami.taskrunner_ami.id
}

output "perm_env_sg_id" {
  value = data.aws_security_group.perm_sg.id
}
