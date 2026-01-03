terraform {
  backend "s3" {
    bucket         = "s3-tfstate-083971419667"
    key            = "resume/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
# terraform init -migrate-state

# Create dynamo db table for lock
# aws dynamodb create-table \
#   --table-name terraform-locks \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1

# Check:
# aws dynamodb describe-table --table-name terraform-locks --region us-east-1

