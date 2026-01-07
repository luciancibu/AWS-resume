from aws_cdk import (
    aws_lambda as _lambda,
    aws_iam as iam,
    aws_dynamodb as dynamodb,
    aws_sns as sns,
    aws_s3 as s3,
    Duration
)
from constructs import Construct


class ComputeConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account: str, region: str, 
                 lambda_role: iam.Role, dynamodb_table: dynamodb.Table, sns_topic: sns.Topic,
                 pdf_lambda_role: iam.Role, pdf_bucket: s3.Bucket, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # View counter Lambda
        self.resume_lambda = _lambda.Function(
            self, "ResumeLambda",
            function_name=f"lambda-terraform-cdk-{account}-{region}",
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler="lambda_function.lambda_handler",
            code=_lambda.Code.from_asset("../Lambda"),
            role=lambda_role,
            timeout=Duration.seconds(5),
            environment={
                "DYNAMODB_TABLE": dynamodb_table.table_name,
                "SNS_TOPIC_ARN": sns_topic.topic_arn,
                "ITEM_ID": "views"
            }
        )

        # Publish 
        version = self.resume_lambda.current_version

        # Alias with weighted routing
        self.resume_lambda_alias = _lambda.Alias(
            self,
            "ProdAlias",
            alias_name="prodcdk",
            version=version,
        )

        # Likes Lambda
        self.likes_lambda = _lambda.Function(
            self, "LikesLambda",
            function_name=f"lambda-likes-{account}-{region}",
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler="lambda_likes.lambda_handler",
            code=_lambda.Code.from_asset("../Lambda"),
            role=lambda_role,
            timeout=Duration.seconds(5),
            environment={
                "DYNAMODB_TABLE": dynamodb_table.table_name,
                "ITEM_ID": "likes"
            }
        )

        # PDF Lambda
        self.pdf_lambda = _lambda.Function(
            self, "PdfLambda",
            function_name=f"lambda-pdf-{account}-{region}",
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler="lambda_pdf.lambda_handler",
            code=_lambda.Code.from_asset("../Lambda"),
            role=pdf_lambda_role,
            timeout=Duration.seconds(5),
            environment={
                "BUCKET_NAME": pdf_bucket.bucket_name,
                "ITEM_NAME": "resume.pdf"
            }
        )
