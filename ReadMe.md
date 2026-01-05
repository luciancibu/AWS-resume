# AWS Serverless Resume with Terraform | Jenkins | GitHub Actions

This repository contains a serverless resume web application deployed on AWS with Infrastructure as Code (Terraform) and automated CI/CD pipelines (Jenkins + GitHub Actions).

- **S3** (static hosting)
- **CloudFront** (HTTPS)
- **Lambda** (Python API)
- **DynamoDB** (persistent counter)
- **Terraform** (Infrastructure as Code)
- **GitHub Actions** (CI/CD pipeline)
- **Jenkins** (CI/CD pipeline running on EC2)

The goal is to build an automated, infrastructure capable of continuously deploying both backend and frontend components.

## Project Structure

```
AWS-resume/
│
├── html/
│     ├── index.html
│     └── styles.css
│
├── Lambda/
│     ├── lambda_function.py
│     ├── lambda_likes.py
│     ├── lambda_rollback.py
│
├── Terraform/
│     ├── S3.tf
│     ├── CloudFront.tf
│     ├── DynamoDb.tf
│     ├── Iam.tf
│     ├── Lambda.tf
│     ├── Instance.tf
│     ├── SecGrp.tf
│     ├── Api.tf
│     ├── CloudWatch.tf
│     ├── Sns.tf
│     ├── Keypair.tf
│     ├── vars.tf
│     ├── provider.tf
│     ├── backend.tf
│     └── setup_Jenkins.sh
│
├── _tests/
│     ├── tests.py
│     ├── db_tests.py
│     └── Jenkins/
│     └── Lambda/
│     └── SNS/
│     └── Terraform/
│
├── .github/workflows/main.yml
├── Jenkinsfile
└── README.md
```

## Infrastructure Overview (Terraform)

### 1. S3 Static Website Hosting  
Terraform provisions a private S3 bucket that stores the static website assets (HTML/CSS).
The bucket does not use S3 Static Website Hosting and is accessible only via CloudFront.

### 2. CloudFront Distribution  
CloudFront serves the website over HTTPS, provides custom domain support, and securely accesses the private S3 bucket using Origin Access Control (OAC).

### 3. DynamoDB Storage  
- **View Counter**: Stores the number of visits using an item with key `{ id: "views" }`
- **Like Counter**: Stores the number of likes using an item with key `{ id: "likes" }`

### 4. IAM Role & Policies  
Lambda is granted read/write privileges on DynamoDB.

### 5. Lambda Functions (Python)  
- **Main Lambda**: Increments and returns the website view counter with visitor analytics
- **Likes Lambda**: Handles GET requests to retrieve current like count and PUT requests to increment likes for the resume
- **Rollback Lambda**: Automated rollback mechanism triggered by CloudWatch alarms
Lambda functions are invoked through API Gateway (HTTP API) and are not publicly exposed.

### 6. API Gateway (HTTP API)
Provides a public HTTPS endpoint for the Lambda function, handling request routing and access control.
The frontend calls API Gateway instead of invoking Lambda directly.

### 7. EC2 Jenkins Server  
Terraform provisions an EC2 instance with Jenkins installed via a bootstrap script.

### 8. Security Groups  
SSH limited to your IP, Jenkins exposed on port 8080.

### 9. GitHub Actions CI/CD  
Deploys the frontend, backend, and invalidates CloudFront cache automatically on push.

### 10. CloudWatch Monitoring  
CloudWatch alarms monitor Lambda function errors and trigger automated rollbacks via SNS.

### 11. SNS Notifications  
SNS topics handle email notifications for new resume views and automated rollback alerts.

### 12. Testing Infrastructure  
Comprehensive test suite including unit tests, integration tests, and infrastructure validation.

### 13. Jenkins CI/CD  
Additional CI/CD pipeline executing Lambda + S3 + CloudFront updates.

## Deployment Flow

```
User → CloudFront → S3 (Static Site)
     ↓
     API Gateway → Lambda Functions → DynamoDB
                        ↓
                    SNS Topics → Email Notifications
                        ↓
                CloudWatch Alarms → Rollback Lambda
```

**Normal Flow:**
1. User visits website → CloudFront serves static content from S3
2. JavaScript calls API Gateway endpoints (`/view` and `/likes`)
3. Lambda functions process requests and update DynamoDB counters
4. Main Lambda sends SNS notification for each view with visitor analytics
5. Likes Lambda handles like button interactions (GET/PUT requests)

**Error Handling Flow:**
1. CloudWatch monitors Lambda function errors
2. If errors exceed threshold → CloudWatch alarm triggers
3. CloudWatch alarm publishes to SNS rollback topic
4. SNS triggers Rollback Lambda function
5. Rollback Lambda automatically reverts to stable version
6. Email notifications sent for both visitor analytics and rollback alerts

CI/CD:

```
GitHub Push → GitHub Actions ────────────────┐
                                              ├ Deploy to AWS
Jenkins (EC2) ───────────────────────────────┘
```

## Public URL

Deployed website is accessible at:

**https://resume.lucian-cibu.xyz**

## Summary

This project demonstrates:

- AWS serverless architecture with monitoring and alerting
- Infrastructure as Code using Terraform with remote state management
- CI/CD pipelines (GitHub Actions & Jenkins)
- API Gateway used as a secure public entry point for Lambda functions
- Dynamic backend using multiple Lambda functions + DynamoDB
- Automated CloudFront cache invalidation
- CloudWatch monitoring with automated rollback capabilities
- SNS-based notification system for visitor analytics
- Lambda versioning and canary deployments
