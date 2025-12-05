pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "lucian-cibu-resume"
        CLOUDFRONT_ID = "EDGGVY01J7KZW"
    }    

  stages {
        stage('Configure AWS Credentials') {
            steps {
                echo 'Configuring AWS Credentials'
                withAWS(credentials: 'awscreds', region: "${AWS_REGION}") {
                    sh 'aws sts get-caller-identity'
                }
            }
        }
        
        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'awscreds', region: "${AWS_DEFAULT_REGION}") {
                    sh """
                        aws s3 sync html/ s3://${S3_BUCKET}/ \
                            --acl public-read \
                            --delete

                        echo "Upload complete."
                    """
                }
            }
        }        
  }
}