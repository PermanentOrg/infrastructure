output "backend_ami" {
  value = data.aws_ami.backend.id
}

output "cron_ami" {
  value = data.aws_ami.cron.id
}

output "taskrunner_ami" {
  value = data.aws_ami.taskrunner.id
}

output "sftp_ami" {
  value = data.aws_ami.sftp.id
}

output "security_group" {
  value = data.aws_security_group.default.id
}

output "subnet" {
  value = data.aws_subnet.default.id
}
