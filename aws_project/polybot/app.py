import flask
from flask import request
import os
import json
from bot import ObjectDetectionBot
import boto3
import collections

app = flask.Flask(__name__)


# TODO load TELEGRAM_TOKEN value from Secret Manager
secret_name = "abed_22_BOT"
region_name = "eu-central-1"
client = boto3.client('secretsmanager', region_name)
response = client.get_secret_value(SecretId=secret_name)
response_json = json.loads(response['SecretString'])

TELEGRAM_TOKEN = response_json['TELEGRAM_BOT_TOKEN']
TELEGRAM_APP_URL = response_json['TELEGRAM_APP_URL']

@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    try:
        bot.handle_message(req['message'])
    except KeyError:
        print("Message key not found in the request.")
    return 'Ok'


@app.route(f'/results/', methods=['GET'])
def results():
    prediction_id = request.args.get('prediction_id')
    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    dynamodb = boto3.resource('dynamodb',region_name='eu-central-1')
    table = dynamodb.Table('abed2')

    response = table.get_item(
        Key={
            'prediction_id': prediction_id
        }
    )

    chat_id = request.args.get('chat_id')
    text_results = response
    labels_string = response.get('Item', {}).get('labels', [])
    labels = json.loads(labels_string)

    class_counts = collections.Counter(item['class'] for item in labels)
    #res = json.dumps(dict(class_counts))
    text_results = "\n".join([f"{key}: {value}" for key, value in class_counts.items()])
    bot.send_text(chat_id, text=f"Object counts:\n{text_results}")
    req = request.get_json()
    return 'Ok'

@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    app.run(host='0.0.0.0', port=8443)
