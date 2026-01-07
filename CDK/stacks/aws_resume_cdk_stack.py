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

class AwsResumeCdkStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        
        storage = StorageConstruct(
            self, "Storage",
            account=self.account,
            region=self.region
        )

        networking = NetworkingConstruct(
            self, "Networking",
            website_bucket=storage.website_bucket,
            account=self.account,
            region=self.region            
        )

        security = SecurityConstruct(
            self, "Security",
            account_id=self.account,
            region=self.region,
        )     
           
        compute = ComputeConstruct(
            self, "Compute",
            account=self.account,
            region=self.region,            
            lambda_role=security.lambda_role
        )        
                