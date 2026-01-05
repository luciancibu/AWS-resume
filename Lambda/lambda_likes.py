import os
import boto3

TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "dynamodb-terraform")
ITEM_ID = os.environ.get("ITEM_ID", "likes")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    method = event.get("httpMethod") or \
             event.get("requestContext", {}).get("http", {}).get("method")
    response = table.get_item(Key={"id": ITEM_ID})
    likes_number = response["Item"]["likes_number"]

    if method == "GET":
        return {
            "statusCode": 200,
            "body": str(likes_number),
        }

    if method == "PUT":

        table.put_item(
            Item={
                "id": ITEM_ID,
                "likes_number": likes_number + 1,
            }
        )

        return {
            "statusCode": 200,
            "body": str(likes_number + 1),
        }
