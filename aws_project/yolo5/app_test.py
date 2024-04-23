import time
import json
import yaml
import os
import boto3
import requests
from pathlib import Path
from detect import run
from loguru import logger

# Load necessary configurations
dynamodb_table = os.environ['Dynamodb_table']
images_bucket = os.environ['BUCKET_NAME']
queue_name = os.environ['SQS_QUEUE_NAME']
region_sqs = os.environ['Region_SQS']

# Initialize AWS clients
sqs_client = boto3.client('sqs', region_name=region_sqs)
s3_client = boto3.client('s3')

# Load object names from COCO dataset
with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']

# Function to process messages from SQS
def process_message(message):
    try:
        # Extract information from the message
        message_data = json.loads(message)
        img_name = message_data['img_name']
        chat_id = message_data['chat_id']
        prediction_id = message_data['prediction_id']

        # Download the original image from S3
        original_img_path = f"data/{img_name}"
        s3_client.download_file(images_bucket, img_name, original_img_path)
        logger.info(f'prediction: {prediction_id}/{original_img_path}. Download img completed')

        # Run object detection on the downloaded image
        run(
            weights='yolov5s.pt',
            data='data/coco128.yaml',
            source=original_img_path,
            project='static/data',
            name=prediction_id,
            save_txt=True
        )

        # Upload the predicted image to S3
        predicted_img_name = f"predicted_{img_name}"
        predicted_img_path = Path(f'static/data/{prediction_id}/{original_img_path}')
        predicted_img_path.rename(predicted_img_path.parent / predicted_img_name)
        s3_client.upload_file(str(predicted_img_path), images_bucket, predicted_img_name)

        # Parse prediction labels
        pred_summary_path = Path(f'static/data/{prediction_id}/labels/{original_img_path.split(".")[0]}.txt')
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

            logger.info(f'prediction: {prediction_id}/{original_img_path}. prediction summary:\n\n{labels}')

            # Store prediction summary in DynamoDB
            prediction_summary = {
                'prediction_id': prediction_id,
                'original_img_path': original_img_path,
                'predicted_img_path': predicted_img_path,
                'labels': labels,
                'time': time.time(),
                'text_results': f"The predicted image is stored in S3 as: {predicted_img_name}",
                'chat_id': chat_id
            }
            dynamodb = boto3.resource('dynamodb')
            table = dynamodb.Table(dynamodb_table)
            table.put_item(Item=prediction_summary)

            # Perform a GET request to Polybot for additional processing
            polybot_url = "http://polybot:8443/results"
            response = requests.get(polybot_url, params={'prediction_id': prediction_id})
            if response.status_code == 200:
                response_data = response.json()
                logger.info(f"Polybot request successful: {response_data}")
            else:
                logger.error(f"Polybot request failed with status code {response.status_code}")

            # Delete the message from the queue
            sqs_client.delete_message(QueueUrl=queue_name, ReceiptHandle=message['ReceiptHandle'])
    except Exception as e:
        logger.error(f"Error processing message: {e}")

# Continuously consume messages from SQS
def consume():
    while True:
        try:
            response = sqs_client.receive_message(QueueUrl=queue_name, MaxNumberOfMessages=1, WaitTimeSeconds=5)
            if 'Messages' in response:
                process_message(response['Messages'][0])
        except Exception as e:
            logger.error(f"Error receiving messages from SQS: {e}")
            time.sleep(5)

if __name__ == "__main__":
    consume()
