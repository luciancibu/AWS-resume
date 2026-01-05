import os
import boto3
import base64

BUCKET_NAME = os.environ.get("BUCKET_NAME", "s3-pdf-083971419667")
ITEM_NAME = os.environ.get("ITEM_NAME", "lucian_cibu_resume.pdf")

s3 = boto3.client("s3")


def lambda_handler(event, context):

    obj = s3.get_object(Bucket=BUCKET_NAME, Key=ITEM_NAME)
    pdf_bytes = obj["Body"].read()

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/pdf",
            "Content-Disposition": f"attachment; filename=\"{ITEM_NAME}\""
        },
        "body": base64.b64encode(pdf_bytes).decode("utf-8"),
        "isBase64Encoded": True
    }
