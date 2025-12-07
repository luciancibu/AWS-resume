import json
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume-lucian-cibu-dynamodb-terraform')

def lambda_handler(event, context):

    if event.get("queryStringParameters", {}).get("read") == "true":
        response = table.get_item(Key={'id': '1'})
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": str(response["Item"]["views"])
        }

    response = table.get_item(Key={'id': '1'})
    views = response['Item']['views'] + 1
    table.put_item(Item={'id': '1', 'views': views})

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": str(views)
    }
