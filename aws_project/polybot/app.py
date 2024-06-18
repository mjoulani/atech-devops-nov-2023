import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3
import json
from botocore.exceptions import ClientError
from functools import reduce


def get_secret():
    secret_name = "tg"
    region_name = "ap-northeast-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
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
    print(secret)
    ans = json.loads(secret)['tg']
    return ans


def read_from_db(prediction_id):
    # Initialize a session using Amazon DynamoDB
    session = boto3.Session(region_name='ap-northeast-2')
    # Initialize the DynamoDB resource
    dynamodb = session.resource('dynamodb')

    # Select your table
    table = dynamodb.Table('bed_skout_DynamoDB_aws_project')

    # Get a specific item by primary key
    response = table.get_item(
        Key={'predictionId': prediction_id}
    )
    item = response.get('Item')
    return item


def get_result_from_response(res):
    labels = res['labels']
    result = {}
    for label in labels:
        label_name = label['class']
        value = result.get(label_name)
        if value is None:
            result[label_name] = 1
        else:
            result[label_name] = value + 1

    result_string = reduce(lambda acc, item: acc + f"{item[0]} {item[1]}\n", result.items(), "Detected objects :\n")
    return result_string


app = flask.Flask(__name__)

# TODO load TELEGRAM_TOKEN value from Secret Manager
TELEGRAM_TOKEN = get_secret()

TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']


@app.route('/', methods=['GET'])
def index():
    print("get req here")
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
    item = read_from_db(prediction_id)
    prediction_summary = json.loads(item['prediction_summary'])
    chat_id = prediction_summary['chat_id']
    text_results = get_result_from_response(prediction_summary)
    bot.send_text(chat_id, text_results)
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    print(TELEGRAM_TOKEN)
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    app.run(host='0.0.0.0', port=8443)
