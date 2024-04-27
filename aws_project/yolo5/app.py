import time
from pathlib import Path
from detect import run
import yaml
from loguru import logger
import os
import boto3
import json
import requests

# Constants
IMAGES_BUCKET = 'abedallah-joulany-bucket'
QUEUE_NAME = 'abedallahjo-polybot-sqs'
REGION_NAME = 'ap-northeast-1'
DYNAMODB_TABLE = 'abedallahjo-table'
APP_URL = 'https://abedallahjo-polybot-alb-1663808701.ap-northeast-1.elb.amazonaws.com'


sqs_client = boto3.client('sqs', region_name=REGION_NAME)
s3_client = boto3.client('s3', region_name=REGION_NAME)
dynamodb = boto3.resource('dynamodb', region_name=REGION_NAME)
table = dynamodb.Table(DYNAMODB_TABLE)

with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']


def download_image(img_name, original_img_path):
    try:
        s3_client.download_file(IMAGES_BUCKET, img_name, original_img_path)
        logger.info(f'Downloaded image from S3: {img_name}')
        return True
    except Exception as e:
        logger.error(f'Error downloading image from S3: {e}')
        return False


def upload_image(predicted_img_path, img_name):
    try:
        predicted_img_key = f'predicted/{img_name[:-4]}_predicted.jpg'
        s3_client.upload_file(str(predicted_img_path), IMAGES_BUCKET, predicted_img_key)
        logger.info(f'Uploaded predicted image to S3: {predicted_img_key}')
        return True
    except Exception as e:
        logger.error(f'Error uploading predicted image to S3: {e}')
        return False


def store_prediction_summary(prediction_id, original_img_path, predicted_img_path, chat_id, labels):
    try:
        obj_str = ', '.join([item['class'] for item in labels])
        table.put_item(
            Item={
                'prediction_id': prediction_id,
                'original_img_path': original_img_path,
                'chat_id': chat_id,
                'labels': obj_str
            }
        )
        logger.info(f'Stored prediction summary in DynamoDB for prediction_id: {prediction_id}')
        return True
    except Exception as e:
        logger.error(f'Error storing prediction summary in DynamoDB: {e}')
        return False


def send_request_to_polybot(prediction_id):
    try:
        url = f'{APP_URL}/results/?predictionId={prediction_id}'
        response = requests.get(url, verify=False)
        logger.info(f'Sent request to Polybot for prediction_id: {prediction_id}. Response: {response.status_code}')
        return True
    except Exception as e:
        logger.error(f'Error sending request to Polybot: {e}')
        return False


def consume():
    while True:
        response = sqs_client.receive_message(QueueUrl=QUEUE_NAME, MaxNumberOfMessages=1, WaitTimeSeconds=5)
 
        if 'Messages' in response:
            logger.info(response)

            message = response['Messages'][0]
            logger.info(message)

            receipt_handle = message.get('ReceiptHandle')
            prediction_id = message.get('MessageId')
            body = message.get('Body')

            # Parse the JSON string to extract image and chat_id
            try:
                body_dict = json.loads(body)
                img_name = body_dict.get('image')
                chat_id = body_dict.get('chat_id')
            except json.JSONDecodeError as e:
                logger.error(f"Error decoding message body JSON: {e}")
                continue

            if not all([receipt_handle, prediction_id, img_name, chat_id]):
                logger.error("Message structure is incomplete. Skipping processing.")
                continue

            logger.info(f'Start processing prediction: {prediction_id}')

            if not download_image(img_name, img_name):
                continue

            # Predicts the objects in the image
            run(
                weights='yolov5s.pt',
                data='data/coco128.yaml',
                source=img_name,
                project='static/data',
                name=prediction_id,
                save_txt=True
            )

            logger.info(f'prediction: {prediction_id}/{img_name}. done')

            # This is the path for the predicted image with labels
            # The predicted image typically includes bounding boxes drawn around the detected objects, along with class labels and possibly confidence scores.
            predicted_img_path = Path(f'static/data/{prediction_id}/{img_name}')

            if not upload_image(predicted_img_path, img_name):
                continue
            pred_summary_path = Path(f'static/data/{prediction_id}/labels/{img_name.split(".")[0]}.txt')
            # logger.info(f'pred_summary_path: {pred_summary_path}')
            if pred_summary_path.exists():
                with open(pred_summary_path) as f:
                    labels = f.read().splitlines()
                    labels = [line.split(' ') for line in labels]
                    labels = [{
                        'class': names[int(l[0])],
                        'cx': float(l[1]),
                        'cy': float(l[2]),
                        'width': float(l[3]),
                        'height': float(l[4]),
                    } for l in labels]

                logger.info(f'Prediction summary for {prediction_id}: {labels}')

                if store_prediction_summary(prediction_id, img_name, predicted_img_path.name, chat_id, labels):
                    send_request_to_polybot(prediction_id)

            sqs_client.delete_message(QueueUrl=QUEUE_NAME, ReceiptHandle=receipt_handle)
            logger.info(f'Deleted message from SQS: {receipt_handle}')


if __name__ == "__main__":
    consume()


# docker build -t yolo-image .
# docker run --restart=always -it -d -p 8443:8443 -v $HOME/.aws/credentials:/root/.aws/credentials  --name yolo-container yolo-image