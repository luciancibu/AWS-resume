from aws_cdk import (
    aws_lambda as _lambda,
    aws_cloudfront as cloudfront,
    aws_cloudfront_origins as origins,
    aws_apigatewayv2 as apigw,
    aws_apigatewayv2_integrations as integrations,    
    aws_logs as logs
)
from constructs import Construct

class NetworkingConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, website_bucket: str, account: str, region: str, 
                resume_lambda_alias: _lambda.IFunction, likes_lambda: _lambda.IFunction, pdf_lambda: _lambda.IFunction, 
                **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # CloudFront Distribution (without custom domain for simplicity)
        self.distribution = cloudfront.Distribution(
            self,
            "ResumeDistribution",
            default_behavior=cloudfront.BehaviorOptions(
                origin=origins.S3Origin(website_bucket),
                viewer_protocol_policy=cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
                cache_policy=cloudfront.CachePolicy.CACHING_OPTIMIZED,
                compress=True,
            ),
            default_root_object="index.html",
            price_class=cloudfront.PriceClass.PRICE_CLASS_100,
            http_version=cloudfront.HttpVersion.HTTP2_AND_3,
        )
        
         # API Gateway
        self.api = apigw.HttpApi(
            self,
            "ResumeApi",
            api_name=f"ResumeApi-cdk-{account}-{region}",
            cors_preflight=apigw.CorsPreflightOptions(
                allow_origins=["*"],
                allow_methods=[apigw.CorsHttpMethod.GET, apigw.CorsHttpMethod.PUT, apigw.CorsHttpMethod.OPTIONS],
                allow_headers=["*"],
            ),
        )
        # Lambda integrations
        view_integration = integrations.HttpLambdaIntegration(
            "ViewIntegration",
            resume_lambda_alias
        )

        likes_integration = integrations.HttpLambdaIntegration(
            "LikesIntegration",
            likes_lambda
        )

        pdf_integration = integrations.HttpLambdaIntegration(
            "PdfIntegration",
            pdf_lambda
        )

        # API Routes
        self.api.add_routes(
            path="/view",
            methods=[apigw.HttpMethod.GET],
            integration=view_integration
        )

        self.api.add_routes(
            path="/likes",
            methods=[apigw.HttpMethod.GET],
            integration=likes_integration
        )

        self.api.add_routes(
            path="/likes",
            methods=[apigw.HttpMethod.PUT],
            integration=likes_integration
        )  

        self.api.add_routes(
            path="/pdf",
            methods=[apigw.HttpMethod.GET],
            integration=pdf_integration
        )

        # CloudWatch logs for API Gateway
        self.api_log_group = logs.LogGroup(
            self, "ApiGwLogs",
            log_group_name="/aws/apigateway/resume-cdk-api-logs",
            retention=logs.RetentionDays.TWO_WEEKS
        )