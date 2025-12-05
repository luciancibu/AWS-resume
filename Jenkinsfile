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
                sh '''
                    aws s3 sync html/ s3://'"${S3_BUCKET}"'/ --delete
                '''
            }
        }

  }
}