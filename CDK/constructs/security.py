from aws_cdk import (
    aws_iam as iam,
    aws_dynamodb as dynamodb,
    aws_sns as sns,
    aws_s3 as s3
)
from constructs import Construct


class SecurityConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account_id: str, region: str,
                 dynamodb_table: dynamodb.Table, sns_topic: sns.Topic, 
                 pdf_bucket: s3.Bucket, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Lambda execution role
        self.lambda_role = iam.Role(
            self, "LambdaRole",
            role_name=f"lambda-role-terraform-{account_id}-{region}",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name("service-role/AWSLambdaBasicExecutionRole")
            ]
        )

        # Lambda policy for DynamoDB
        self.lambda_role.add_to_policy(
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                actions=[
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem"
                ],
                resources=[dynamodb_table.table_arn]
            )
        )

        self.lambda_role.add_to_policy(
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                actions=["sns:Publish"],
                resources=[sns_topic.topic_arn]
            )
        )

        # Lambda PDF execution role
        self.pdf_lambda_role = iam.Role(
            self, "PdfLambdaRole",
            role_name=f"lambda-role-pdf-{account_id}-{region}",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name("service-role/AWSLambdaBasicExecutionRole")
            ]
        )

        # Lambda PDF policy for DynamoDB
        self.pdf_lambda_role.add_to_policy(
          iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                actions=["s3:GetObject"],
                resources=[f"{pdf_bucket.bucket_arn}/lucian_cibu_resume.pdf"]
            )
        )        

        # Rollback Lambda role
        self.rollback_lambda_role = iam.Role(
            self, "RollbackLambdaRole",
            role_name=f"rollback-lambda-role-{account_id}-{region}",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name("service-role/AWSLambdaBasicExecutionRole")
            ]
        )

        self.rollback_lambda_role.add_to_policy(
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                actions=[
                    "lambda:GetAlias",
                    "lambda:UpdateAlias"
                ],
                resources=[f"arn:aws:lambda:{region}:{account_id}:function:*"]
            )
        )