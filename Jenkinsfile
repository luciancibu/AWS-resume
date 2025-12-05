pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "lucian-cibu-resume"
        CLOUDFRONT_ID = "EDGGVY01J7KZW"
    }    

  stages {
   
        stage('Checkout HTML repo') {
            steps {
                // sshagent(['github-ssh-key']) {
                    // sh 'git clone git@github.com:luciancibu/AWS-resume.git'
                // }
                echo 'Test'
            }
        }
  }
}