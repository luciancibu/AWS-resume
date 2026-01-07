from aws_cdk import (
    Duration,
    aws_cloudfront as cloudfront,
    aws_cloudfront_origins as origins,
    aws_apigatewayv2 as apigw,

)
from constructs import Construct

class NetworkingConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, website_bucket: str, account: str, region: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # CloudFront Distribution (without custom domain for simplicity)
        self.distribution = cloudfront.Distribution(
            self, "ResumeDistribution",
            default_behavior=cloudfront.BehaviorOptions(
                origin=origins.S3Origin(
                    bucket=website_bucket,
                ),
                viewer_protocol_policy=cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
                compress=True,
                cache_policy=cloudfront.CachePolicy.CACHING_OPTIMIZED
            ),
            default_root_object="index.html",
            price_class=cloudfront.PriceClass.PRICE_CLASS_100,
            http_version=cloudfront.HttpVersion.HTTP2_AND_3
        )
        