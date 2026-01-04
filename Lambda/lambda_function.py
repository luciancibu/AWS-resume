import os
import boto3

TABLE_NAME = os.environ["DYNAMODB_TABLE"]
ITEM_ID = os.environ.get("ITEM_ID", "views")
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

sns = boto3.client("sns")


def lambda_handler(event, context):
    raise Exception("FORCED ERROR FOR TESTING")
