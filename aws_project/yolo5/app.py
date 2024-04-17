import json
import time
from pathlib import Path
from detect import run
import yaml
from loguru import logger
import os
import boto3
import requests

images_bucket = os.environ['BUCKET_NAME']
queue_name = os.environ['SQS_QUEUE_NAME']

sqs_client = boto3.client('sqs', region_name='eu-north-1')
s3 = boto3.client('s3')
with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']


def insertData(prediction_id, img_name, labels, chat_id):
    dynamodb = boto3.client('dynamodb', region_name='eu-north-1')
    table_name = "hamad-aws-project-db"
    item = {
        'prediction_id': {'S': prediction_id},
        'chat_id': {'S': str(chat_id)},
        'description': {'S': json.dumps({'img_name': img_name, 'labels': labels})}
    }

    # Store the item in the DynamoDB table
    response = dynamodb.put_item(
        TableName=table_name,
        Item=item
    )

    # Check if the item was stored successfully
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print("Item stored successfully")
    else:
        print("Failed to store item:", response['ResponseMetadata']['HTTPStatusCode'])


def consume():
    while True:
        response = sqs_client.receive_message(QueueUrl=queue_name, MaxNumberOfMessages=1, WaitTimeSeconds=5)

        if 'Messages' in response:
            message = response['Messages'][0]['Body']
            receipt_handle = response['Messages'][0]['ReceiptHandle']

            # Use the ReceiptHandle as a prediction UUID
            prediction_id = response['Messages'][0]['MessageId']

            logger.info(f'prediction: {prediction_id}. start processing')

            # Receives a URL parameter representing the image to download from S3 MessageBody=photo_key
            message_list = message['Body'].split(',')
            img_name = message_list[0]  # TODO extract from `message`done
            chat_id = message_list[1]  # TODO extract from `message`done
            original_img_path = str(
                img_name)  # TODO download img_name from S3, store the local image path in original_img_path done
            s3.download_file(images_bucket, img_name, original_img_path)

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

            # TODO Uploads the predicted image (predicted_img_path) to S3 (be careful not to override the original image). done
            the_image = "predicted_" + original_img_path
            s3.upload_file(str(predicted_img_path), images_bucket, the_image)
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
                    'time': time.time()
                }

                # TODO store the prediction_summary in a DynamoDB table
                insertData(prediction_id, img_name, labels, chat_id)
                # TODO perform a GET request to Polybot to `/results` endpoint
                url = f"https://polybot-lb-842977370.eu-north-1.elb.amazonaws.com/results/?predictionId={prediction_id}"
                requests.get(url=url, verify=False)
            # Delete the message from the queue as the job is considered as DONE
            sqs_client.delete_message(QueueUrl=queue_name, ReceiptHandle=receipt_handle)


if __name__ == "__main__":
    consume()
