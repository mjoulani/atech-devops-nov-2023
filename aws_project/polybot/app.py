import flask
from flask import request
import os
from bot import ObjectDetectionBot, Bot
import boto3
from botocore.exceptions import ClientError
import json

app = flask.Flask(__name__)

def get_secret():

    secret_name = "oferbakria_telebot"
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
    # Parse the JSON string
    secret_data = json.loads(secret)
    
    # Access the value associated with the 'teleBot' key
    telebot_value = secret_data['teleBot']
    
    return telebot_value
    
TELEGRAM_TOKEN = get_secret()
TELEGRAM_APP_URL = "https://oferbakria-loadbalancer-1920523343.eu-west-1.elb.amazonaws.com"
  
@app.route('/', methods=['GET'])
def index():
    return 'Ok Bro'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
