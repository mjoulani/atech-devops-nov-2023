import boto3
import flask
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from flask import request
import os
from bot import ObjectDetectionBot
from bot import Bot
from loguru import logger
import boto3
import json

app = flask.Flask(__name__)

load_dotenv()

def get_telegram_token_from_secret_manager():

    secret_name = "abedallahjo-TelegramToken"
    region_name = "ap-northeast-1"

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

    response = get_secret_value_response['SecretString']

    secret = json.loads(response)

    return secret['TelegramToken']

#TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
TELEGRAM_TOKEN = "6782214342:AAHfconU3WhLBNau2NiB7umZpK8dteWfnxk"
#get_telegram_token_from_secret_manager()
print(TELEGRAM_TOKEN)

TELEGRAM_APP_URL ="abedallahjo-polybot-alb-1663808701.ap-northeast-1.elb.amazonaws.com"

# sqs_client = boto3.client('sqs', region_name='YOUR_REGION_HERE')
# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='ap-northeast-1')
table_name = 'abedallahjo-table'  # Replace with your DynamoDB table name
table = dynamodb.Table(table_name)



@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    print("%$%$")
    logger.info(f'webhook\n\n')
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results/', methods=['GET'])
def results():
    prediction_id = request.args.get('predictionId')
    logger.info(f'prediction: {prediction_id}. start processing')
    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    # Retrieve results from DynamoDB
    response = table.get_item(Key={'prediction_id': prediction_id})

    logger.info(f'results: {response}. end processing')
    
    chat_id = response['Item']['chat_id']
    text_results = response['Item']['labels']
    logger.info(f'chat_id :{chat_id}, text_results : {text_results}')

    bot.send_text(chat_id, text_results)
    return 'Ok'


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    logger.info(f'load_test\n\n')
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    #bot = Bot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    #print(get_telegram_token_from_secret_manager())
    app.run(host='0.0.0.0', port=8443)
