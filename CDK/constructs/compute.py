from aws_cdk import (
    aws_lambda as _lambda,
    aws_iam as iam,
    Duration
)
from constructs import Construct


class ComputeConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account: str, region: str, 
                 lambda_role: iam.Role, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # View counter Lambda
        self.resume_lambda = _lambda.Function(
            self, "ResumeLambda",
            function_name=f"lambda-terraform-cdk-{account}-{region}",
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler="lambda_function.lambda_handler",
            code=_lambda.Code.from_asset("../Lambda"),
            role=lambda_role,
            timeout=Duration.seconds(5)
        )