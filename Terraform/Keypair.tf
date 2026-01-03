# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "Jenkins_terraform-key" {
  key_name   = "Jenkins_terraform-key"
  public_key = tls_private_key.tls_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "./${aws_key_pair.Jenkins_terraform-key.key_name}.pem"
  content         = tls_private_key.tls_key.private_key_pem
  file_permission = "0400"
}
