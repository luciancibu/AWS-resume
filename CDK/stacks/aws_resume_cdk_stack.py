from constructs import Construct
from aws_cdk import (
    Stack,
    CfnOutput,
    aws_iam as iam,
)

from constructs.storage import StorageConstruct
from constructs.networking import NetworkingConstruct
from constructs.security import SecurityConstruct
from constructs.compute import ComputeConstruct
from constructs.monitoring import MonitoringConstruct


class AwsResumeCdkStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        
        storage = StorageConstruct(
            self, "Storage",
            account=self.account,
            region=self.region
        )

        monitoring = MonitoringConstruct(
            self, "Monitoring",
            account=self.account,
            region=self.region,
            notification_email="luciancibu@yahoo.com"
        )

        security = SecurityConstruct(
            self, "Security",
            account_id=self.account,
            region=self.region,
            dynamodb_table=storage.dynamodb_table,
            sns_topic=monitoring.resume_sns_topic,
            pdf_bucket=storage.pdf_bucket,
        )

        compute = ComputeConstruct(
            self, "Compute",
            account=self.account,
            region=self.region,
            lambda_role=security.lambda_role,
            pdf_lambda_role=security.pdf_lambda_role,
            rollback_lambda_role=security.rollback_lambda_role,            
            dynamodb_table=storage.dynamodb_table,
            sns_topic=monitoring.resume_sns_topic,
            pdf_bucket=storage.pdf_bucket,
        )

        # Update monitoring with Lambda references
        monitoring.setup_lambda_monitoring(
            rollback_lambda=compute.rollback_lambda,
            resume_lambda=compute.resume_lambda,
            account=self.account,
            region=self.region            
        )

        # Add SNS policy to Lambda role after topic creation
        security.lambda_role.add_to_policy(
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                actions=["sns:Publish"],
                resources=[monitoring.resume_sns_topic.topic_arn]
            )
        )

        networking = NetworkingConstruct(
            self, "Networking",
            website_bucket=storage.website_bucket,
            resume_lambda_alias=compute.resume_lambda_alias,
            likes_lambda=compute.likes_lambda,
            pdf_lambda=compute.pdf_lambda,
            account=self.account,
            region=self.region
        )

        # Outputs
        CfnOutput(
            self, "CloudFrontDistributionId",
            value=networking.distribution.distribution_id,
            description="CloudFront distribution ID"
        )

        CfnOutput(
            self, "ApiGatewayUrl",
            value=networking.api.url,
            description="API Gateway URL"
        )
