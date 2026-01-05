# TLS Private Key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Key Pair
resource "aws_key_pair" "jenkins_key" {
  key_name   = "Jenkins_terraform-key"
  public_key = tls_private_key.tls_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "./${aws_key_pair.jenkins_key.key_name}.pem"
  content         = tls_private_key.tls_key.private_key_pem
  file_permission = "0400"
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins_terraform-sg"
  description = "Jenkins_terraform-sg"
  
  ingress {
    description = "Allow ssh from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Allow 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound IPv6"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name    = "Jenkins_terraform-sg"
    Project = "resume"
  }
}


# EC2 Instance (optional - can be enabled/disabled)
resource "aws_instance" "jenkins" {
  count = var.enable_jenkins ? 1 : 0
  
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  availability_zone      = var.availability_zone

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "Jenkins_terraform"
    Project = "resume"
  }

  provisioner "file" {
    source      = var.jenkins_setup_script
    destination = "/tmp/setup_Jenkins.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.tls_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_Jenkins.sh",
      "sudo /tmp/setup_Jenkins.sh"
    ]
  }
}