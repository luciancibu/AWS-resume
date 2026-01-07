from aws_cdk import (
    RemovalPolicy,
    aws_s3 as s3,
    aws_dynamodb as dynamodb,
)
from constructs import Construct

class StorageConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, account: str, region: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        
        # S3 Bucket for website hosting
        self.website_bucket = s3.Bucket(
            self,
            "WebsiteBucket",
            bucket_name=f"s3-terraform-cdk-{account}-{region}",
            public_read_access=False,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            encryption=s3.BucketEncryption.S3_MANAGED,
            removal_policy=RemovalPolicy.DESTROY,
        )

        self.pdf_bucket = s3.Bucket(
            self,
            "PdfBucket",
            bucket_name=f"s3-pdf-cdk-{account}-{region}",
            public_read_access=False,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            encryption=s3.BucketEncryption.S3_MANAGED,
            removal_policy=RemovalPolicy.DESTROY,
        )          

        # DynamoDB table
        self.dynamodb_table = dynamodb.Table(
            self, "ResumeTable",
            table_name=f"dynamodb-terraform-{account}-{region}",
            partition_key=dynamodb.Attribute(
                name="id",
                type=dynamodb.AttributeType.STRING
            ),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,
            point_in_time_recovery=True,
            removal_policy=RemovalPolicy.DESTROY
        )