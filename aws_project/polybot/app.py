import json
import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3
from bot import ObjectDetectionBot, Bot, QuoteBot

app = flask.Flask(__name__)

# Retrieve environment variables
region_db = os.environ['Region_Dynamodb']
dynamodb_table = os.environ['Dynamodb_table']
s3_bucket = os.environ['BUCKET_NAME']
queue_name = os.environ['SQS_QUEUE_NAME']
TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']
region_secret = os.environ.get('Region_secret')
region_s3 = os.environ.get('Region_S3')
region_sqs = os.environ.get('Region_SQS')


#s3_bucket = 'naghambucket'
#queue_name = 'Sabaa_SQS'
#TELEGRAM_APP_URL = 'https://9df9-77-126-174-121.ngrok-free.app'
#region_secret = 'eu-central-1'
#region_s3 = 'us-east-2'
#region_sqs = 'us-east-1'
#region_secret = os.environ.get('Region_SECRET')check name please
#region_s3=os.environ.get('Region_SQS')
#region_sqs=os.environ.get('Region_S3')


# Retrieve the TELEGRAM_TOKEN value from Secrets Manager
secrets_manager_client = boto3.client('secretsmanager', region_name=region_secret)
response = secrets_manager_client.get_secret_value(SecretId='telegram-bot-token')
data = json.loads(response['SecretString'])
TELEGRAM_TOKEN = data['TELEGRAM_TOKEN']

# Define routes
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

    # Retrieve prediction results from DynamoDB
    dynamodb_client = boto3.client('dynamodb', region_name=region_db)
    response = dynamodb_client.get_item(
        TableName=dynamodb_table,
        Key={'prediction_id': {'S': prediction_id}}
    )
    chat_id = response['Item']['chat_id']['S']
    # Format and send text results to the user
    text_results = formatted_message(response.get('Item', {}))
    bot.send_text(chat_id, text_results)
    return 'Ok'

def formatted_message(prediction_data):
    obj_count = {}
    formatted_string = f"Detected Objects:\n"
    for label in prediction_data.get("labels", []):
        class_name = label.get("class")
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
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL, s3_bucket, region_s3, queue_name, region_sqs)
    app.run(host='0.0.0.0', port=8443, debug=True)
