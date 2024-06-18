import time
from pathlib import Path
from detect import run
import yaml
from loguru import logger
import os
import boto3
import json
import requests

images_bucket = "abed-skout-aws-project-buket"
queue_name = "https://sqs.ap-northeast-2.amazonaws.com/933060838752/abed-skout-sqs-aws-project.fifo"

sqs_client = boto3.client('sqs', region_name='ap-northeast-2')

with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']


def consume():
    while True:
        response = sqs_client.receive_message(QueueUrl=queue_name, MaxNumberOfMessages=1, WaitTimeSeconds=5)
        print("-----------------------------------")
        print(response)
        print("-----------------------------------")

        if 'Messages' in response:
            message = response['Messages'][0]['Body']
            print("-----------------------------------")
            print(message)
            print("-----------------------------------")

            receipt_handle = response['Messages'][0]['ReceiptHandle']

            # Use the ReceiptHandle as a prediction UUID
            prediction_id = response['Messages'][0]['MessageId']

            logger.info(f'prediction: {prediction_id}. start processing')

            # Receives a URL parameter representing the image to download from S3
            json_msg = json.loads(message)
            img_name = json_msg["image_name"]
            chat_id = json_msg["chat_id"]  # TODO extract from `message`
            print("-----------------------------------")
            print(chat_id)
            print("-----------------------------------")
            download_image(img_name)
            original_img_path = download_image(
                img_name)  # TODO download img_name from S3, store the local image path in original_img_path

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
            name, extension = img_name.rsplit('.', 1)
            image_name_after_prdeict = f'{name}_after_predict.{extension}'
            upload_file_to_s3(image_name_after_prdeict, predicted_img_path)

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
                    'chat_id': chat_id,
                    'prediction_id': prediction_id,
                    'original_img_path': str(original_img_path),
                    'predicted_img_path': str(predicted_img_path),
                    'labels': labels,
                    'time': time.time()
                }
                prediction_summary_string = json.dumps(prediction_summary)
                # TODO store the prediction_summary in a DynamoDB table
                upload_to_DynamoDB(prediction_id, prediction_summary_string)
                # TODO perform a GET request to Polybot to `/results` endpoint
                notify_polybot("http://10.0.0.7:8443/results", prediction_id)
            # Delete the message from the queue as the job is considered as DONE
            sqs_client.delete_message(QueueUrl=queue_name, ReceiptHandle=receipt_handle)


def download_image(image_name):
    s3_client = boto3.client('s3')
    with open(image_name, 'wb') as f:
        s3_client.download_fileobj(images_bucket, image_name, f)
    return image_name


def upload_file_to_s3(object_name, image_path):
    # Upload the file
    s3_client = boto3.client('s3')
    print("image_path is " + str(image_path))
    try:
        s3_client.upload_file(image_path, images_bucket, object_name)
        print(f"File {image_path} uploaded to {images_bucket}/{object_name}")
        return True
    except NoCredentialsError:
        print("Credentials not available")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False


def upload_to_DynamoDB(prediction_id, prediction_summary):
    session = boto3.Session(region_name='ap-northeast-2')
    dynamodb = session.resource('dynamodb')
    table = dynamodb.Table('bed_skout_DynamoDB_aws_project')
    item = {
        'predictionId': prediction_id,
        'prediction_summary': prediction_summary
    }
    table.put_item(Item=item)


def notify_polybot(url, prediction_id):
    params = {
        'predictionId': prediction_id
    }
    requests.get(url, params=params)


if __name__ == "__main__":
    consume()
