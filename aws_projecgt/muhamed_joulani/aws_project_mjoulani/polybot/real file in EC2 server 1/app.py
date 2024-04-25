import flask
import boto3
import json
import telebot
import os
import time
import requests
from flask import request
from loguru import logger
from botocore.exceptions import ClientError
from telebot.types import InputFile
from bot import ObjectDetectionBot
from collections import Counter


app = flask.Flask(__name__)


# TODO load TELEGRAM_TOKEN value from Secret Manager
def get_secret():
    secret_name = "muh_token"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        # Retrieve the secret value
        response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # Handle exceptions
        error_message = f"Failed to retrieve secret '{secret_name}' from Secrets Manager: {e}"
        raise ValueError(error_message) from None

    # Extract the secret string from the response
    if 'SecretString' in response:
        secret_string = response['SecretString']
    else:
        raise ValueError("Secret value not found in response.")

    # Parse the JSON string to extract the value associated with the key "muh_token"
    try:
        secret_value = json.loads(secret_string)['muh_token']
    except json.JSONDecodeError:
        raise ValueError("Failed to parse secret value as JSON.") from None

    return secret_value

TELEGRAM_TOKEN = get_secret()

TELEGRAM_APP_URL = os.environ['WEBHOOK_URL']
#TELEGRAM_APP_URL = 'https://muh-aws-alb-1133477302.us-west-1.elb.amazonaws.com/'

logger.info(f"TELEGRAM_TOKEN: {TELEGRAM_TOKEN}")
logger.info(f"TELEGRAM_APP_URL: {TELEGRAM_APP_URL}")





@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results/', methods=['GET'])
def results():
    # Get the prediction ID from the query parameters
    prediction_id = request.args.get('predictionId')

    # Store data in DynamoDB
    dynamodb_resource = boto3.resource('dynamodb', region_name='us-west-1')
    table_name = 'prediction_summary'
    table = dynamodb_resource.Table(table_name)

    try:
        # Retrieve the item from the DynamoDB table
        response = table.get_item(
            Key={
                'prediction_id': prediction_id
            }
        )

        # Check if the item was found
        if 'Item' in response:
            item = response['Item']
            logger.info("Item retrieved successfully:")
            logger.info(item)
            #to do send data to telegram
        else:
            logger.info("Item not found.")
    except Exception as e:
        logger.error("Error retrieving item:", exc_info=True)

    # Extract labels
    labels = item.get('labels', [])
    chat_id = item.get('chat_id', [])

    # Get the path from dbymanodb to download the predicted file
    predicted_img_path = item.get('original_img_path', [])
    logger.info(f"the pre_file : {predicted_img_path}")
    download_path = '/usr/src/app/'
    bucket_name = os.environ['BUCKET_NAME']
    # Extract the file name from the file path
    file_name = os.path.basename(predicted_img_path)
    logger.info(f"file_name : {file_name}")
    file_path = os.path.join(download_path, file_name)
    logger.info(f"file_path : {file_path}")
    # Create an S3 client and Download file
    s3 = boto3.client('s3')
    s3.download_file(bucket_name, file_name, file_path)
    print(f"File downloaded from S3 to {file_path}")

    # Extract class names
    class_names = [label.get('class') for label in labels]
    result = "\n".join([f"{class_name} : {count}" for class_name, count in Counter(class_names).items()])
    try:
        logger.info(f"File path before sending photo: {file_path}")
        bot.send_photo_rep(chat_id, file_path)
    finally:
        # Regardless of whether the photo was sent successfully or not, delete the file
            os.remove(file_path)

    text_results = "Detected objects:\n" + result
    bot.send_text(chat_id, text_results)
    return 'Ok'


    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user

    #chat_id = ...
    #text_results = ...

    #bot.send_text(chat_id, text_results)
    #prediction_id = request.args.get('predictionId')

    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user

    #chat_id = ...
    #text_results = ...

    #bot.send_text(chat_id, text_results)



@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
