from constructs import Construct
from aws_cdk import (
    Duration,
    Stack,
    aws_iam as iam,
    aws_sqs as sqs,
    aws_sns as sns,
    aws_s3 as s3,
    aws_sns_subscriptions as subs,
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
            dynamodb_table=storage.dynamodb_table,
            sns_topic=monitoring.resume_sns_topic,
            pdf_lambda_role=security.pdf_lambda_role,
            pdf_bucket=storage.pdf_bucket,
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

