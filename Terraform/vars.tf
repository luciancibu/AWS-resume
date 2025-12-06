
variable "region" {
  default = "us-east-1"
}

variable "zone" {
  default = "us-east-1a"
}

variable "user" {
  default = "ubuntu"
}

variable "amiID" {
  default = "ami-0ecb62995f68bb549"
}

variable "rootDomainName" {
  default = "lucian-cibu.xyz"
}

variable "tableName" {
  default = "resume-lucian-cibu-dynamodb-terraform"
}
