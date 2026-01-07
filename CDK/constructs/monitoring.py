from aws_cdk import (
    aws_sns as sns,
    aws_sns_subscriptions as subscriptions,
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