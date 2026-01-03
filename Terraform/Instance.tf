# # Documentation References:
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# # https://developer.hashicorp.com/terraform/language/provisioners

# resource "aws_instance" "Jenkins_terraform" {
#   ami                    = var.amiID
#   instance_type          = "t2.medium"
#   key_name               = aws_key_pair.Jenkins_terraform-key.key_name
#   vpc_security_group_ids = [aws_security_group.Jenkins_terraform-sg.id]
#   availability_zone      = var.zone
#   tags = {
#     Name    = "Jenkins_terraform"
#     Project = "resume"
#   }

#   provisioner "file" {
#     source      = "setup_Jenkins.sh"
#     destination = "/tmp/setup_Jenkins.sh"
#   }

#   connection {
#     type        = "ssh"
#     user        = var.user
#     private_key = file("C:/Users/Luci/.ssh/id_rsa")
#     host        = self.public_ip
#   }

#   provisioner "remote-exec" {

#     inline = [
#       "chmod +x /tmp/setup_Jenkins.sh",
#       "sudo /tmp/setup_Jenkins.sh"
#     ]
#   }

# }

# resource "aws_ec2_instance_state" "Jenkins_terraform-state" {
#   instance_id = aws_instance.Jenkins_terraform.id
#   state       = "running"
# }

# output "JenkinsPublicIP" {
#   value = aws_instance.Jenkins_terraform.public_ip
# }