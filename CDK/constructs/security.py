from aws_cdk import (
    aws_iam as iam,
)
from constructs import Construct


class SecurityConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account_id: str, region: str, **kwargs) -> None:
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