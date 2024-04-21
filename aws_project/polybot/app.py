import json
import flask
from flask import request
import os
from bot import ObjectDetectionBot
from loguru import logger
import boto3
from botocore.exceptions import ClientError


app = flask.Flask(__name__)

def get_secret():
    secret_name = "daniel-telegram"
    region_name = "eu-west-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response['SecretString']
    secret = json.loads(secret)

    return secret['TELEGRAM_TOKEN']


# TODO load TELEGRAM_TOKEN value from Secret Manager
#TELEGRAM_TOKEN = '6521616754:AAGPxWVhiBfOKZSwWJ4THvVreggYD5S9Keg'
TELEGRAM_TOKEN = get_secret()
logger.info(f'yourkey {TELEGRAM_TOKEN}')


TELEGRAM_APP_URL = 'https://Daniel-LB-1354148717.eu-west-1.elb.amazonaws.com'


@app.route('/', methods=['GET'])
def index():
    return 'Ok normal'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results/', methods=['GET'])
def results():
    prediction_id = request.args.get('predictionId')

    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user

    chat_id = ...
    text_results = ...

    bot.send_text(chat_id, text_results)
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
