import os
import boto3

LAMBDA_FUNCTION_NAME = os.environ["TARGET_FUNCTION_NAME"]
ALIAS_NAME = os.environ.get("ALIAS_NAME", "prod")
STABLE_VERSION = os.environ["STABLE_VERSION"]

lambda_client = boto3.client("lambda")


def lambda_handler(event, context):
    # Update alias to stable version
    lambda_client.update_alias(
        FunctionName=LAMBDA_FUNCTION_NAME,
        Name=ALIAS_NAME,
        FunctionVersion=STABLE_VERSION,
        RoutingConfig={}  # remove canary routing => 100% stable version
    )

    return {
        "statusCode": 200,
        "body": f"Rolled back {ALIAS_NAME} to version {STABLE_VERSION}"
    }
