import os
import boto3

TABLE_NAME = os.environ["DYNAMODB_TABLE"]
ITEM_ID = os.environ.get("ITEM_ID", "views")
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

sns = boto3.client("sns")


def lambda_handler(event, context):

    params = event.get("queryStringParameters") or {}
    response = table.get_item(Key={"id": ITEM_ID})
    views = response["Item"]["views"]

    if params.get("read") == "true":
        return {
            "statusCode": 200,
            "body": str(views),
        }

    table.put_item(
        Item={
            "id": ITEM_ID,
            "views": views + 1
            })

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="CV viewed",
        Message=f"CV was viewed. Total views: {views}",
    )

    return {
        "statusCode": 200,
        "body": str(views),
    }
