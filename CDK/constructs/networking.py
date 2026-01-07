from aws_cdk import (
    aws_lambda as _lambda,
    aws_cloudfront as cloudfront,
    aws_cloudfront_origins as origins,
    aws_apigatewayv2 as apigw,
    aws_apigatewayv2_integrations as integrations,    

)
from constructs import Construct

class NetworkingConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, website_bucket: str, account: str, region: str, 
                resume_lambda_alias: _lambda.IFunction, **kwargs) -> None:
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
        
         # API Gateway
        self.api = apigw.HttpApi(
            self,
            "ResumeApi",
            api_name=f"ResumeApi-cdk-{account}-{region}"
        )

        # Lambda integrations
        view_integration = integrations.HttpLambdaIntegration(
            "ViewIntegration",
            resume_lambda_alias
        )

        # API Routes
        self.api.add_routes(
            path="/view",
            methods=[apigw.HttpMethod.GET],
            integration=view_integration
        )