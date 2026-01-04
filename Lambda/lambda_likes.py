import os
import boto3

TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "dynamodb-terraform")
ITEM_ID = os.environ.get("ITEM_ID", "likes")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    response = table.get_item(Key={"id": ITEM_ID})
    likes_number = int(response["Item"].get("likes_number", 0)) + 1

    table.put_item(
        Item={
            "id": ITEM_ID,
            "likes_number": likes_number,
        }
    )
    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": str(likes_number),
    }
