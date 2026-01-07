from aws_cdk import (
    aws_lambda as _lambda,
    aws_iam as iam,
    aws_dynamodb as dynamodb,
    aws_sns as sns,
    Duration
)
from constructs import Construct


class ComputeConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account: str, region: str, 
                 lambda_role: iam.Role, dynamodb_table: dynamodb.Table, sns_topic: sns.Topic,
                **kwargs) -> None:
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