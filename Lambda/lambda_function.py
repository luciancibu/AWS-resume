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

    if params.get("read") == "true":
        response = table.get_item(Key={"id": ITEM_ID})
        views = response.get("Item", {}).get("views", 0)

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": str(views),
        }

    response = table.get_item(Key={"id": ITEM_ID})
    views = response["Item"]["views"] + 1
    table.put_item(Item={"id": ITEM_ID, "views": views})

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="CV viewed",
        Message=f"CV was viewed. Total views: {views}",
    )

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": str(views),
    }
