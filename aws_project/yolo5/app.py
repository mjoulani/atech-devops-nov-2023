import time
from pathlib import Path
from detect import run
import yaml
from loguru import logger
import os
import boto3
import json
import requests

dynamodb_table = os.environ['Dynamodb_table']
images_bucket = os.environ['BUCKET_NAME']
queue_name = os.environ['SQS_QUEUE_NAME']
#region_name = os.environ['AWS_REGION']


sqs_client = boto3.client('sqs')
s3_client = boto3.client('s3')

with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']


def consume():
    while True:
        response = sqs_client.receive_message(QueueUrl=queue_name, MaxNumberOfMessages=1, WaitTimeSeconds=5)

        if 'Messages' in response:
            message = response['Messages'][0]['Body']
            receipt_handle = response['Messages'][0]['ReceiptHandle']

            # Use the ReceiptHandle as a prediction UUID
            prediction_id = response['Messages'][0]['MessageId']

            logger.info(f'prediction: {prediction_id}. start processing')

            # Receives a URL parameter representing the image to download from S3
            img_name = ...  # TODO extract from `message`
            chat_id = ...  # TODO extract from `message`
            message_data = json.loads(message)
            img_name = message_data['img_name']
            chat_id = message_data['chat_id']
            original_img_path = ...  # TODO download img_name from S3, store the local image path in original_img_path
            original_img_path = f"data/{img_name}"
            s3_client.download_file(images_bucket, img_name, original_img_path)

            logger.info(f'prediction: {prediction_id}/{original_img_path}. Download img completed')

            # Predicts the objects in the image
            run(
                weights='yolov5s.pt',
                data='data/coco128.yaml',
                source=original_img_path,
                project='static/data',
                name=prediction_id,
                save_txt=True
            )

            logger.info(f'prediction: {prediction_id}/{original_img_path}. done')

            # This is the path for the predicted image with labels
            # The predicted image typically includes bounding boxes drawn around the detected objects, along with class labels and possibly confidence scores.
            predicted_img_path = Path(f'static/data/{prediction_id}/{original_img_path}')

            # TODO Uploads the predicted image (predicted_img_path) to S3 (be careful not to override the original image).
            # Construct the new filename for the predicted image
            predicted_img_name = f"predicted_{img_name}"
            # Rename the predicted image file
            predicted_img_path.rename(predicted_img_path.parent / predicted_img_name)
            # Upload the renamed predicted image to S3
            s3_client.upload_file(str(predicted_img_path), images_bucket, predicted_img_name)

            # Parse prediction labels and create a summary
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

                prediction_summary = {
                    'prediction_id': prediction_id,
                    'original_img_path': original_img_path,
                    'predicted_img_path': predicted_img_path,
                    'labels': labels,
                    'time': time.time(),
                    'text_results': f"The predicted image is stored in S3 as: {predicted_img_name}",
                    'chat_id': chat_id  # Include chat_id if available
                }

                # TODO store the prediction_summary in a DynamoDB table
                # Initialize DynamoDB client and table resource
                dynamodb = boto3.resource('dynamodb')
                table = dynamodb.Table(dynamodb_table)

                # Put item into DynamoDB table
                table.put_item(Item=prediction_summary)
                # TODO perform a GET request to Polybot to `/results` endpoint
                polybot_url = "http://polybot:8443/results"
                response = requests.get(polybot_url, params={'prediction_id': prediction_id})
                if response.status_code == 200:
                    # Request was successful, process response content
                    response_data = response.json()  # Convert response content to JSON
                    print(f"Request passed {response_data}")
                else:
                    # Request failed, handle the error
                    print(f"Request failed with status code {response.status_code}")
                # Delete the message from the queue as the job is considered as DONE
                sqs_client.delete_message(QueueUrl=queue_name, ReceiptHandle=receipt_handle)


if __name__ == "__main__":
    consume()
