# AWS Serverless Resume with Terraform | CDK | Jenkins | GitHub Actions

This repository contains a serverless resume web application deployed on AWS with Infrastructure as Code (Terraform + CDK) and automated CI/CD pipelines (GitHub Actions).

- **S3** (static hosting + Lambda backup + PDF storage)
- **CloudFront** (HTTPS distribution)
- **Lambda** (4 Python functions: views, likes, PDF download, rollback)
- **DynamoDB** (view/like counters)
- **API Gateway** (HTTP API endpoints)
- **Terraform** (modular Infrastructure as Code)
- **AWS CDK** (Python-based Infrastructure as Code alternative)
- **GitHub Actions** (CI/CD with matrix deployment)
- **CloudWatch + SNS** (monitoring and notifications)

## Project Structure

```
AWS-resume/
│
├── html/
│     ├── index.html
│     └── styles.css
│
├── Lambda/
│     ├── .pylintrc
│     ├── lambda_function.py         # View counter + SNS notifications
│     ├── lambda_likes.py            # Like counter (GET/PUT)
│     ├── lambda_pdf.py              # PDF download from S3
│     └── lambda_rollback.py         # Automated rollback handler
│
├── Terraform/
│     ├── main.tf                    # Root module configuration
│     ├── variables.tf               # Root variables
│     ├── outputs.tf                 # Root outputs
│     ├── provider.tf                # Provider configuration
│     ├── backend.tf                 # Remote state backend
│     ├── setup_Jenkins.sh           # Jenkins EC2 setup script
│     ├── README_MODULES.md          # Module documentation
│     ├── .tfsec/config.yml          # TFSec security configuration
│     └── modules/
│           ├── storage/             # S3 buckets + DynamoDB + cross-account policies
│           ├── compute/             # Lambda functions with versioning
│           ├── networking/          # CloudFront + API Gateway + routes
│           ├── security/            # IAM roles/policies for all services
│           ├── monitoring/          # CloudWatch alarms + SNS topics
│           └── infrastructure/      # Optional EC2 Jenkins server
│
├── CDK/
│     ├── app.py                     # CDK application entry point
│     ├── cdk.json                   # CDK configuration
│     ├── requirements.txt           # Python dependencies
│     ├── requirements-dev.txt       # Development dependencies
│     ├── stacks/
│     │     └── aws_resume_cdk_stack.py  # Main CDK stack
│     ├── constructs/
│     │     ├── storage.py           # S3 + DynamoDB constructs
│     │     ├── compute.py           # Lambda constructs
│     │     ├── networking.py        # CloudFront + API Gateway constructs
│     │     ├── security.py          # IAM constructs
│     │     └── monitoring.py        # CloudWatch + SNS constructs
│     └── tests/
│           └── unit/                # CDK unit tests
│
├── .github/workflows/
│     └── main.yml                   # Matrix-based CI/CD pipeline (Terraform + CDK)
│
├── _tests/                          # Test files (excluded from deployment)
├── .gitignore
├── Jenkinsfile
└── README.md
```

## Infrastructure Overview

The infrastructure can be deployed using either **Terraform modules** or **AWS CDK constructs**:

### Terraform Implementation
The Terraform infrastructure is organized into reusable modules:

### Module Architecture
- **Storage Module**: 4 S3 buckets (website, tfstate, PDF, Lambda backup) + DynamoDB table + cross-account policies
- **Compute Module**: 4 Lambda functions with versioning and aliases
- **Networking Module**: CloudFront distribution + API Gateway HTTP API + 4 routes
- **Security Module**: IAM roles and policies for all Lambda functions
- **Monitoring Module**: CloudWatch alarms + SNS topics for notifications
- **Infrastructure Module**: Optional EC2 Jenkins server

### 1. S3 Storage (4 Buckets)
- **Website Bucket**: Private S3 bucket for static assets (HTML/CSS), accessible only via CloudFront OAC
- **Terraform State Bucket**: Remote state storage with versioning enabled
- **PDF Bucket**: Stores resume PDF files for download functionality
- **Lambda Backup Bucket**: Stores Lambda function backups for rollback, includes cross-account access policy for account 083971419667

### 2. CloudFront Distribution
Serves website over HTTPS with custom domain (resume.lucian-cibu.xyz) using Origin Access Control (OAC).

### 3. DynamoDB Table
- **View Counter**: Item with key `{ id: "views" }` tracks website visits
- **Like Counter**: Item with key `{ id: "likes" }` tracks resume likes

### 4. Lambda Functions (Python 3.12)
- **lambda_function.py**: View counter with SNS notifications for each visit
- **lambda_likes.py**: Like system (GET to retrieve, PUT to increment)
- **lambda_pdf.py**: PDF download from S3 with base64 encoding
- **lambda_rollback.py**: Automated rollback triggered by CloudWatch alarms

### 5. API Gateway (HTTP API)
4 routes with CORS configuration:
- `GET /view` → View counter Lambda
- `GET /likes` → Likes Lambda (retrieve)
- `PUT /likes` → Likes Lambda (increment)
- `GET /pdf` → PDF download Lambda

### 6. Monitoring & Notifications
- **CloudWatch Alarms**: Monitor Lambda errors and trigger rollbacks
- **SNS Topics**: Email notifications for views and rollback alerts

### 7. Security
- **IAM Roles**: Separate roles for each Lambda function with least privilege
- **Cross-Account Access**: Lambda backup bucket accessible from account 083971419667

## Deployment Flow

```
User → CloudFront → S3 (Static Site)
     ↓
     API Gateway (4 routes) → Lambda Functions → DynamoDB/S3
                                    ↓
                              SNS Topics → Email Notifications
                                    ↓
                            CloudWatch Alarms → Rollback Lambda
```

**Normal Flow:**
1. User visits website → CloudFront serves static content from S3
2. JavaScript calls API Gateway endpoints:
   - `GET /view` → Increment view counter + SNS notification
   - `GET /likes` → Retrieve current like count
   - `PUT /likes` → Increment like counter
   - `GET /pdf` → Download resume PDF from S3
3. Lambda functions process requests and update DynamoDB/S3
4. View Lambda sends SNS notification for each visit

**Error Handling & Rollback:**
1. CloudWatch monitors Lambda function errors
2. If errors exceed threshold → CloudWatch alarm triggers
3. SNS publishes to rollback topic → Rollback Lambda executes
4. Rollback Lambda reverts to stable version using aliases
5. Email notifications sent for both analytics and rollback alerts

**CI/CD Pipelines:**

```
GitHub Push → GitHub Actions (Matrix Strategy) ──── Deploy to AWS
                ├ Terraform Deployment             
                └ CDK Deployment                   
                                                    
```

## CI/CD Features

### GitHub Actions (Matrix Strategy)
- **Path-based deployment**: Only deploys changed components (HTML, Lambda, Terraform, CDK)
- **Matrix deployment**: Deploys 4 Lambda functions in parallel with individual configurations
- **Dual Infrastructure**: Supports both Terraform and CDK deployments
- **Versioning**: Main Lambda uses versioning with aliases and canary deployments
- **Rollback**: Automatic rollback on smoke test failures
- **Code Quality**: Flake8 linting and Pylint static analysis
- **Security**: TFSec security scanning for Terraform
- **Backup**: Non-versioned Lambdas backed up to S3 before deployment

### AWS CDK Implementation
The CDK implementation provides an alternative Infrastructure as Code approach:

- **Python-based IaC**: Type-safe infrastructure definitions with IDE support
- **Construct Library**: 5 reusable constructs (Storage, Compute, Networking, Security, Monitoring)
- **Built-in Best Practices**: Automatic security and operational configurations
- **CloudFormation Integration**: Leverages AWS CloudFormation for deployment
- **Account/Region Specific**: Configured for account 083971419667 in us-east-1
- **Unified Stack**: Single stack deployment with modular constructs

## Public URL

**https://resume.lucian-cibu.xyz**

## Summary

- **Dual Infrastructure Approach**: Terraform modules + AWS CDK constructs for flexible deployment
- **Modular Architecture**: 6 reusable Terraform modules + 5 CDK constructs with clear separation of concerns
- **Serverless Architecture**: 4 Lambda functions + API Gateway + DynamoDB + S3
- **Multi-Pipeline CI/CD**: GitHub Actions (matrix strategy) + path filtering and automated rollbacks
- **Infrastructure as Code**: Both Terraform (HCL) and CDK (Python) implementations
- **Monitoring & Alerting**: CloudWatch alarms + SNS notifications + automated rollback
- **Security**: Cross-account S3 policies, IAM least privilege, private buckets with OAC, TFSec scanning
- **Scalability**: Lambda versioning, aliases, and canary deployments
- **Code Quality**: Automated linting, static analysis, and smoke testing
- **Multi-functionality**: View counter, like system, PDF downloads, and visitor analytics
