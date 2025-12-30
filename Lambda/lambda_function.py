import json
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume-lucian-cibu-dynamodb-terraform')
ITEM_ID = 'views'

def lambda_handler(event, context):

    if event.get("queryStringParameters", {}).get("read") == "true":
        response = table.get_item(Key={'id': ITEM_ID})
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": str(response["Item"]["views"])
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
