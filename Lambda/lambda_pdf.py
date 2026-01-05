# import os
# import boto3

def lambda_handler(event, context):
    print("Test")
    # method = event.get("httpMethod") or \
    #          event.get("requestContext", {}).get("http", {}).get("method")
    # response = table.get_item(Key={"id": ITEM_ID})
    # likes_number = response["Item"]["likes_number"]

    # if method == "GET":
    #     return {
    #         "statusCode": 200,
    #         "body": str(likes_number),
    #     }

    # if method == "PUT":

    #     table.put_item(
    #         Item={
    #             "id": ITEM_ID,
    #             "likes_number": likes_number + 1,
    #         }
    #     )

    #     return {
    #         "statusCode": 200,
    #         "body": str(likes_number + 1),
    #     }
