# AWS Serverless Resume with Terraform | Jenkins | GitHub Actions

This repository contains a serverless resume web application deployed on AWS with Infrastructure as Code (Terraform) and automated CI/CD pipelines (Jenkins + GitHub Actions).

- **S3** (static hosting + Lambda backup + PDF storage)
- **CloudFront** (HTTPS distribution)
- **Lambda** (4 Python functions: views, likes, PDF download, rollback)
- **DynamoDB** (view/like counters)
- **API Gateway** (HTTP API endpoints)
- **Terraform** (modular Infrastructure as Code)
- **GitHub Actions** (CI/CD with matrix deployment)
- **Jenkins** (alternative CI/CD pipeline)
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
│     └── modules/
│           ├── storage/             # S3 buckets + DynamoDB + cross-account policies
│           ├── compute/             # Lambda functions with versioning
│           ├── networking/          # CloudFront + API Gateway + routes
│           ├── security/            # IAM roles/policies for all services
│           ├── monitoring/          # CloudWatch alarms + SNS topics
│           └── infrastructure/      # Optional EC2 Jenkins server
│
├── .github/workflows/
│     └── main.yml                   # Matrix-based CI/CD pipeline
│
├── _tests/                          # Test files (excluded from deployment)
├── .gitignore
├── Jenkinsfile
└── README.md
```

## Infrastructure Overview (Terraform Modules)

The infrastructure is organized into reusable Terraform modules:

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

### 8. Optional Jenkins Infrastructure
EC2 instance with Jenkins, security groups, and SSH key pair.

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
GitHub Push → GitHub Actions (Matrix Strategy) ────┐
                                                    ├ Deploy to AWS
Jenkins (EC2) ─────────────────────────────────────┘
```

## CI/CD Features

### GitHub Actions (Matrix Strategy)
- **Path-based deployment**: Only deploys changed components (HTML, Lambda, Terraform)
- **Matrix deployment**: Deploys 4 Lambda functions in parallel with individual configurations
- **Versioning**: Main Lambda uses versioning with aliases and canary deployments
- **Rollback**: Automatic rollback on smoke test failures
- **Code Quality**: Flake8 linting and Pylint static analysis
- **Backup**: Non-versioned Lambdas backed up to S3 before deployment

### Jenkins Pipeline
- Alternative CI/CD pipeline running on EC2
- Deploys Lambda functions and syncs HTML to S3
- CloudFront cache invalidation

## Public URL

**https://resume.lucian-cibu.xyz**

## Summary

- **Modular Terraform Architecture**: 6 reusable modules with clear separation of concerns
- **Serverless Architecture**: 4 Lambda functions + API Gateway + DynamoDB + S3
- **CI/CD**: Matrix-based deployments with path filtering and automated rollbacks
- **Monitoring & Alerting**: CloudWatch alarms + SNS notifications + automated rollback
- **Security**: Cross-account S3 policies, IAM least privilege, private buckets with OAC
- **Scalability**: Lambda versioning, aliases, and canary deployments
- **Code Quality**: Automated linting, static analysis, and smoke testing
- **Multi-functionality**: View counter, like system, PDF downloads, and visitor analytics
