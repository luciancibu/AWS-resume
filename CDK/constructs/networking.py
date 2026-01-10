from aws_cdk import (
    aws_lambda as _lambda,
    aws_cloudfront as cloudfront,
    aws_cloudfront_origins as origins,
    aws_apigatewayv2 as apigw,
    aws_apigatewayv2_integrations as integrations,    
    aws_logs as logs,
    aws_certificatemanager as acm,
    Fn

)
from constructs import Construct

class NetworkingConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str, website_bucket: str, account: str, region: str, 
                resume_lambda_alias: _lambda.IFunction, likes_lambda: _lambda.IFunction, pdf_lambda: _lambda.IFunction, 
                **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # ACM Certificate for CloudFront
        certificate = acm.Certificate.from_certificate_arn(
            self,
            "ResumeWildcardCert",
            "arn:aws:acm:us-east-1:083971419667:certificate/4a7a34ba-11ad-4555-ad9d-47a3e9adebf5",
        )
        
         # API Gateway
        self.api = apigw.HttpApi(
            self,
            "ResumeApi",
            api_name=f"ResumeApi-cdk-{account}-{region}",
        )        

        # CloudFront Distribution
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
            domain_names=["resume.kakosnita.xyz"],
            certificate=certificate,            
        )

        api_origin = origins.HttpOrigin(
            Fn.select(2, Fn.split("/", self.api.api_endpoint))
        )
        
        self.distribution.add_behavior(
            "/api/*",
            api_origin,
            viewer_protocol_policy=cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
            allowed_methods=cloudfront.AllowedMethods.ALLOW_ALL,
            cache_policy=cloudfront.CachePolicy.CACHING_DISABLED,
            origin_request_policy=cloudfront.OriginRequestPolicy.ALL_VIEWER_EXCEPT_HOST_HEADER,
            compress=True,
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
            path="/api/view",
            methods=[apigw.HttpMethod.GET],
            integration=view_integration
        )

        self.api.add_routes(
            path="/api/likes",
            methods=[apigw.HttpMethod.GET],
            integration=likes_integration
        )

        self.api.add_routes(
            path="/api/likes",
            methods=[apigw.HttpMethod.PUT],
            integration=likes_integration
        )  

        self.api.add_routes(
            path="/api/pdf",
            methods=[apigw.HttpMethod.GET],
            integration=pdf_integration
        )

        # CloudWatch logs for API Gateway
        self.api_log_group = logs.LogGroup(
            self, "ApiGwLogs",
            log_group_name="/aws/apigateway/resume-cdk-api-logs",
            retention=logs.RetentionDays.TWO_WEEKS
        )
        