pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "lucian-cibu-resume"
        CLOUDFRONT_ID = "EDGGVY01J7KZW"
    }    

  stages {
        stage('Upload to S3') {
            steps {
                withAWS(credentials: 'awscreds', region: "${AWS_REGION}") {
                    sh """
                        aws s3 sync html/ s3://${S3_BUCKET}/ \
                            --acl public-read \
                            --delete

                        echo "Upload complete."
                    """
                }
            }
        }

        stage('Invalidate CloudFront Cache') {
            steps {
                withAWS(credentials: 'awscreds', region: "${AWS_REGION}") {
                    sh """
                        aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_ID} --paths "/*"

                        echo "CloudFront cache invalidation initiated."
                    """
                }
            }
        }
  }
}