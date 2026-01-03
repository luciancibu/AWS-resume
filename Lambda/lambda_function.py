import json
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('dynamodb-terraform')
ITEM_ID = 'views'

def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}

    if params.get("read") == "true":
        response = table.get_item(Key={"id": ITEM_ID})
        views = response.get("Item", {}).get("views", 0)

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": str(views)
        }

    response = table.get_item(Key={'id': ITEM_ID})
    views = response['Item']['views'] + 1
    table.put_item(Item={'id': ITEM_ID, 'views': views})

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": str(views)
    }

