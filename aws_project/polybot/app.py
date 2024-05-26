import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3
from botocore.exceptions import ClientError
from loguru import logger
import json

app = flask.Flask(__name__)


# TODO load TELEGRAM_TOKEN value from Secret Manager

def get_secret():
    secret_name = "telegram-polybot-token"
    region_name = "ap-northeast-2"

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
        raise e

    secret = get_secret_value_response['SecretString']
    secret = json.loads(secret)

    return secret['TELEGRAM_TOKEN']

TELEGRAM_TOKEN = get_secret()

TELEGRAM_APP_URL = "ahmad-baloum-1107395860.ap-northeast-2.elb.amazonaws.com"


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
    prediction_id = request.args.get('predictionId')

    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    dynamodb = boto3.resource('dynamodb', region_name='ap-northeast-2')
    table = dynamodb.Table('ahmadbaloum-db')
    response = table.get_item(
        Key={
            'polybot': prediction_id
        }
    )
    logger.info(f'results: {response}')

    item = response['Item']
    chat_id = item['chat_id']
    labels = item['labels']

    class_counts = {}
    for label in labels:
        class_name = label['class']
        if class_name in class_counts:
            class_counts[class_name] += 1
        else:
            class_counts[class_name] = 1

    response_list = [f"{class_name}: {count}" for class_name, count in class_counts.items()]
    response_to_enduser = '\n'.join(response_list)

    logger.info(f'chat_id: {chat_id}, response_to_enduser: {response_to_enduser}')


    bot.send_text(chat_id, f'Prediction Results:\n{response_to_enduser}')
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
