# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

resource "aws_key_pair" "Jenkins_terraform-key" {
  key_name   = "Jenkins_terraform-key"
  public_key = file("C:/Users/Luci/.ssh/id_rsa.pub")
}
