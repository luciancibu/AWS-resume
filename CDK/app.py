#!/usr/bin/env python3

import aws_cdk as cdk

from stacks.aws_resume_cdk_stack import AwsResumeCdkStack


app = cdk.App()
AwsResumeCdkStack(app, "AwsResumeCdkStack",
    env=cdk.Environment(
        account="083971419667",
        region="us-east-1"
        )
    )

app.synth()
