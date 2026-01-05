variable "enable_jenkins" {
  description = "Whether to create Jenkins EC2 instance"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for EC2 instance"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
}

variable "jenkins_setup_script" {
  description = "Path to Jenkins setup script"
  type        = string
}