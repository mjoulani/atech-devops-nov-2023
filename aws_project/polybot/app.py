import boto3
import flask
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from flask import request
import os
from bot import ObjectDetectionBot
from loguru import logger

app = flask.Flask(__name__)

load_dotenv()

def get_telegram_token_from_secret_manager():

    secret_name = "TelegramToken"
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

    secret = get_secret_value_response['SecretString']
    return secret

TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
#TELEGRAM_TOKEN = get_telegram_token_from_secret_manager()

TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']

# sqs_client = boto3.client('sqs', region_name='YOUR_REGION_HERE')
# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='ap-northeast-1')
table_name = 'ObjectDetectionResults'  # Replace with your DynamoDB table name
table = dynamodb.Table(table_name)



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
    logger.info(f'prediction: {prediction_id}. start processing')
    # TODO use the prediction_id to retrieve results from DynamoDB and send to the end-user
    # Retrieve results from DynamoDB
    response = table.get_item(Key={'prediction_id': prediction_id})
    item = response.get('Item', {})
    text_results = item.get('results', 'Results not found')  # Replace 'results' with your attribute name

    chat_id = response['Item']['chat_id']
    logger.info(f'chat_id :{chat_id}, text_results : {text_results}')

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
