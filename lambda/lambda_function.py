import json
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume-lucian-cibu')

def lambda_handler(event, context):
    response = table.get_item(Key={'id': '0'})
    views = response['Item']['views'] + 1
    table.put_item(Item={'id': '0', 'views': views})
    print("Test")

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",   
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "GET"
        },
        "body": str(views)
    }
