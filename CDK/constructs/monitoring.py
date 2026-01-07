from aws_cdk import (
    aws_sns as sns,
    aws_sns_subscriptions as subscriptions,
    aws_lambda as _lambda,
    aws_cloudwatch as cloudwatch,
    aws_cloudwatch_actions as cw_actions,
    aws_iam as iam,
    Duration

)
from constructs import Construct


class MonitoringConstruct(Construct):
    def __init__(self, scope: Construct, construct_id: str,
                account: str, region: str, notification_email: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # SNS Topic for resume notifications
        self.resume_sns_topic = sns.Topic(
            self, "ResumeSNSTopic",
            topic_name=f"SNS-resume-{account}-{region}"
        )

        self.resume_sns_topic.add_subscription(
            subscriptions.EmailSubscription(notification_email)
        )

        # SNS Topic for rollback notifications
        self.rollback_sns_topic = sns.Topic(
            self, "RollbackSNSTopic",
            topic_name=f"lambda-rollback-topic-{account}-{region}"
        )

        self.rollback_sns_topic.add_subscription(
            subscriptions.EmailSubscription(notification_email)
        )

    def setup_lambda_monitoring(self, rollback_lambda: _lambda.Function, resume_lambda: _lambda.Function, account: str, region: str):
        # Add Lambda subscription to rollback topic
        self.rollback_sns_topic.add_subscription(
            subscriptions.LambdaSubscription(rollback_lambda)
        )

        # Grant SNS permission to invoke rollback Lambda
        rollback_lambda.add_permission(
            "AllowSNSTriggerRollback",
            principal=iam.ServicePrincipal("sns.amazonaws.com"),
            source_arn=self.rollback_sns_topic.topic_arn
        )

        # CloudWatch Alarm for Lambda errors
        self.lambda_error_alarm = cloudwatch.Alarm(
            self, "LambdaProdErrors",
            alarm_name=f"lambda-prod-errors-{account}-{region}",
            metric=cloudwatch.Metric(
                namespace="AWS/Lambda",
                metric_name="Errors",
                dimensions_map={
                    "FunctionName": resume_lambda.function_name,
                    "Resource": f"{resume_lambda.function_name}:prod"
                },
                statistic="Sum",
                period=Duration.minutes(5)
            ),
            threshold=1,
            evaluation_periods=2,
            comparison_operator=cloudwatch.ComparisonOperator.GREATER_THAN_OR_EQUAL_TO_THRESHOLD,
            treat_missing_data=cloudwatch.TreatMissingData.NOT_BREACHING
        )

        self.lambda_error_alarm.add_alarm_action(
            cw_actions.SnsAction(self.rollback_sns_topic)
        )