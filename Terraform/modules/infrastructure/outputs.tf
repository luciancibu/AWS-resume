output "jenkins_public_ip" {
  description = "Public IP of Jenkins instance"
  value       = var.enable_jenkins ? aws_instance.jenkins[0].public_ip : null
}

output "jenkins_security_group_id" {
  description = "ID of Jenkins security group"
  value       = aws_security_group.jenkins_sg.id
}

output "private_key_path" {
  description = "Path to private key file"
  value       = local_file.private_key.filename
}
