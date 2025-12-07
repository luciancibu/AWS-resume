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
├── lambda/
│     └── lambda_function.py
│
├── terraform/
│     ├── S3.tf
│     ├── CloudFront.tf
│     ├── DynamoDb.tf
│     ├── Iam.tf
│     ├── Lambda.tf
│     ├── Instance.tf
│     ├── SecGrp.tf
│     ├── Keypair.tf
│     ├── Vars.tf
│     ├── provider.tf
│
├── .github/workflows/main.yml
├── Jenkinsfile
└── README.md
```

## Infrastructure Overview (Terraform)

### 1. S3 Static Website Hosting  
Terraform configures a public S3 bucket for hosting the resume website.

### 2. CloudFront Distribution  
CloudFront provides HTTPS and custom domain support.

### 3. DynamoDB View Counter  
Stores the number of visits using an item with key `{ id: "views" }`.

### 4. IAM Role & Policies  
Lambda is granted read/write privileges on DynamoDB.

### 5. Lambda Function (Python)  
Serverless backend increments and returns the website view counter.

### 6. EC2 Jenkins Server  
Terraform provisions an EC2 instance with Jenkins installed via a bootstrap script.

### 7. Security Groups  
SSH limited to your IP, Jenkins exposed on port 8080.

### 8. GitHub Actions CI/CD  
Deploys the frontend, backend, and invalidates CloudFront cache automatically on push.

### 9. Jenkins CI/CD  
Additional CI/CD pipeline executing Lambda + S3 + CloudFront updates.

## Deployment Flow

```
User → CloudFront → S3 (Static Site)
                 ↘ Lambda → DynamoDB
```

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

- AWS serverless architecture
- Infrastructure as Code using Terraform
- Two CI/CD pipelines (GitHub Actions & Jenkins)
- Dynamic backend using Lambda + DynamoDB
- Automated CloudFront cache invalidation
- Production-level DevOps workflow
