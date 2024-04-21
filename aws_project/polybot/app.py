import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3

app = flask.Flask(__name__)
dynamodb_table = os.environ['Dynamodb_table']
s3_bucket = os.environ['BUCKET_NAME']
queue_name = os.environ['SQS_QUEUE_NAME']
TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']
#region_name = os.environ['AWS_REGION']

# TODO load TELEGRAM_TOKEN value from Secret Manager
# Initialize a Secrets Manager client
secrets_manager_client = boto3.client('secretsmanager')
# Retrieve the TELEGRAM_TOKEN value from Secret Manager
response = secrets_manager_client.get_secret_value(SecretId='telegram-bot-token')
TELEGRAM_TOKEN = response['SecretString']



# @app.before_first_request
# def load_telegram_token():
#     global TELEGRAM_TOKEN
#     # Initialize a Secrets Manager client
#     secrets_manager_client = boto3.client('secretsmanager')
#
#     # Retrieve the TELEGRAM_TOKEN value from Secret Manager
#     response = secrets_manager_client.get_secret_value(SecretId='TELEGRAM_TOKEN_SECRET_ID')
#     TELEGRAM_TOKEN = response['SecretString']

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
    # Initialize DynamoDB client
    dynamodb_client = boto3.client('dynamodb')
    response = dynamodb_client.get_item(
        TableName=dynamodb_table,
        Key={
            'prediction_id': {'S': prediction_id}
        }
    )
    chat_id = response['Item']['chat_id']['S']
    #bot.send_text(chat_id, text_results)
    #text_results = response['Item']['text_results']['S']
    prediction_data = response.get('Item', {})  # Get the item, or an empty dictionary if it doesn't exist
    # Format the message using the retrieved data
    text_results = formatted_message(prediction_data)
    return 'Ok'

def formatted_message(prediction_data):
        obj_count = {}
        formatted_string = f"Detected Objects:\n"
        for label in prediction_data["labels"]:
            class_name = label["class"]
            if class_name in obj_count:
                obj_count[class_name] += 1
            else:
                obj_count[class_name] = 1
        for key, value in obj_count.items():
            formatted_string += f"{key}: {value}\n"
        return formatted_string


@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL, s3_bucket, queue_name)

    app.run(host='0.0.0.0', port=8443)
