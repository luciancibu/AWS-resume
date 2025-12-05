pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "lucian-cibu-resume"
        CLOUDFRONT_ID = "EDGGVY01J7KZW"
        LAMBDA_FUNCTION = "lucian-cibu-resume-api" 
    }    

  stages {
        stage('Zip Lambda Function') {
            steps {
                sh """
                    cd lambda
                    zip -r ../lambda.zip .
                """
            }
        }

        // stage('Deploy Lambda Function') {
        //     steps {
        //         withAWS(credentials: 'awscreds', region: AWS_REGION) {
        //             sh """
        //                 aws lambda update-function-code \
        //                     --function-name ${LAMBDA_FUNCTION} \
        //                     --zip-file fileb://lambda.zip
        //             """
        //         }
        //     }
        // }

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
    post{
        success{
            echo "Deployment complete!"
        }
        failure{
            echo "Deployment failed!"
        }
    }   
}