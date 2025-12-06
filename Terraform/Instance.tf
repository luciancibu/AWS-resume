resource "aws_instance" "Jenkins_terraform" {
  ami                    = data.aws_ami.amiID.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.Jenkins_terraform-key.key_name
  vpc_security_group_ids = [aws_security_group.Jenkins_terraform-sg.id]
  availability_zone      = "us-east-1a"

  tags = {
    Name    = "Jenkins_terraform"
    Project = "Jenkins_terraform"
  }
}

resource "aws_ec2_instance_state" "Jenkins_terraform-state" {
  instance_id = aws_instance.Jenkins_terraform.id
  state       = "running"
}