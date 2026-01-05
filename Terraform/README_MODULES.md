# Terraform Modular Architecture

This directory contains a modular Terraform configuration for the AWS Serverless Resume project.

## Module Structure

```
Terraform/
├── main.tf                    # Main configuration orchestrating all modules
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
├── provider.tf                # Provider configuration
├── backend.tf                 # Remote state configuration
└── modules/
    ├── storage/               # S3 buckets and DynamoDB
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/               # Lambda functions
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── networking/            # CloudFront, API Gateway, S3 policies
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/              # IAM roles and policies
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── monitoring/            # CloudWatch, SNS
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── infrastructure/        # EC2 Jenkins (optional)
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Modules Overview

### 1. Storage Module (`modules/storage/`)
- **Purpose**: Manages data storage resources
- **Resources**:
  - S3 bucket for static website hosting
  - S3 bucket for Terraform state (tfstate)
  - DynamoDB table for counters
- **Outputs**: Bucket IDs, ARNs, domain names, table name/ARN

### 2. Compute Module (`modules/compute/`)
- **Purpose**: Manages serverless compute resources
- **Resources**:
  - Main Lambda function (view counter)
  - Likes Lambda function
  - Rollback Lambda function
  - Lambda aliases and versioning
- **Outputs**: Function names, ARNs, invoke ARNs

### 3. Networking Module (`modules/networking/`)
- **Purpose**: Manages networking and content delivery
- **Resources**:
  - CloudFront distribution with OAC
  - API Gateway HTTP API
  - API routes and integrations
  - Lambda permissions for API Gateway
  - S3 bucket policy for CloudFront access
- **Outputs**: CloudFront domain, API Gateway URL

### 4. Security Module (`modules/security/`)
- **Purpose**: Manages IAM roles and policies
- **Resources**:
  - Lambda execution role and policies
  - Rollback Lambda role and policies
- **Outputs**: Role ARNs

### 5. Monitoring Module (`modules/monitoring/`)
- **Purpose**: Manages monitoring and alerting
- **Resources**:
  - SNS topics for notifications
  - CloudWatch alarms
  - SNS subscriptions
  - Lambda permissions for SNS
- **Outputs**: SNS topic ARNs

### 6. Infrastructure Module (`modules/infrastructure/`)
- **Purpose**: Manages optional EC2 infrastructure
- **Resources**:
  - EC2 instance for Jenkins (optional)
  - Security groups
  - Key pairs
  - TLS private keys
- **Outputs**: Jenkins public IP, security group ID

## Usage

### Deploy All Resources
```bash
terraform init
terraform plan
terraform apply
```

### Deploy Without Jenkins
The Jenkins EC2 instance is disabled by default. To enable it:
```bash
terraform apply -var="enable_jenkins=true"
```

### Module Dependencies
The modules have the following dependency order:
1. **storage** (independent)
2. **monitoring** (independent)
3. **security** (depends on storage, monitoring)
4. **compute** (depends on security, storage, monitoring)
5. **networking** (depends on storage, compute)
6. **infrastructure** (independent, optional)

## Benefits of Modular Architecture

1. **Reusability**: Modules can be reused across different environments
2. **Maintainability**: Each module has a single responsibility
3. **Testing**: Modules can be tested independently
4. **Scalability**: Easy to add new modules or modify existing ones
5. **Organization**: Clear separation of concerns
6. **Collaboration**: Teams can work on different modules independently

## Migration from Monolithic Structure

The original flat structure has been refactored into modules:
- `S3.tf` → `modules/storage/`
- `Lambda.tf` → `modules/compute/`
- `CloudFront.tf` + `Api.tf` → `modules/networking/`
- `Iam.tf` → `modules/security/`
- `CloudWatch.tf` + `Sns.tf` → `modules/monitoring/`
- `Instance.tf` + `SecGrp.tf` + `Keypair.tf` → `modules/infrastructure/`

## Variables

Key variables can be customized in `variables.tf`:
- `enable_jenkins`: Enable/disable Jenkins EC2 instance
- `notification_email`: Email for SNS notifications
- `root_domain_name`: Domain for the website
- `allowed_ssh_cidr`: IP range for SSH access
- `stable_lambda_version`: Version for rollback functionality

## Outputs

Main outputs include:
- `website_url`: The public website URL
- `api_gateway_url`: API Gateway endpoint
- `jenkins_public_ip`: Jenkins server IP (if enabled)
- `s3_bucket_name`: Website S3 bucket name
- `dynamodb_table_name`: Counter table name