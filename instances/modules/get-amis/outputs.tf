output "backend_ami_id" {
  value = data.aws_ami.backend.id
}

output "cron_ami_id" {
  value = data.aws_ami.cron.id
}

output "taskrunner_ami_id" {
  value = data.aws_ami.taskrunner.id
}

output "perm_env_sg_id" {
  value = data.aws_security_group.default.id
}
