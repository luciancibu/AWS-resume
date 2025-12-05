pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "lucian-cibu-resume"
        CLOUDFRONT_ID = "EDGGVY01J7KZW"
    }    

  stages {
   
        stage('Fetch code') {
            steps {
               git branch: 'main', url: 'https://github.com/luciancibu/AWS-resume.git'
               sh 'echo "Code fetched successfully!"'
            }
        }
        
        stage('Deploy to S3') {
            steps {
                s3Upload(
                    bucket: "${S3_BUCKET}",
                    includePathPattern: "**/*.html,**/*.css",
                    workingDir: "html",
                    acl: "PublicRead"
                )
            }
        }

  }
}