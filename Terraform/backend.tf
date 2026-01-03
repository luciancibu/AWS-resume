terraform {
  backend "s3" {
    bucket = "s3-tfstate-083971419667"
    key    = "resume/terraform.tfstate"
    region = "us-east-1"
  }
}
