import time
from pathlib import Path
import boto3
from flask import Flask, request, jsonify
import uuid
import yaml
from loguru import logger
import os
from pymongo import MongoClient
from detect import run
from dotenv import load_dotenv
import botocore.exceptions
import traceback


load_dotenv()
bucket_name = os.getenv('BUCKET_NAME')

with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    # Generates a UUID for this current prediction HTTP request. This id can be used as a reference in logs to identify and track individual prediction requests.
    prediction_id = str(uuid.uuid4())
    logger.info(f'prediction: {prediction_id}. start processing')
    img_name = request.args.get('imgName')
    if not bucket_name:
        return jsonify({'error': 'Bucket name not provided'}), 500
    original_img_path = f'{img_name}'
    s3_yolo = boto3.client('s3')
    try:
        s3_yolo.download_file(bucket_name, img_name, original_img_path)
        #print("Hssd")
        logger.info(f'prediction: {prediction_id}/{original_img_path}. Download img completed')
    except botocore.exceptions.ClientError as e:
        error_code = e.response.get('Error', {}).get('Code')
        error_message = e.response.get('Error', {}).get('Message')
        logger.error(f'Error downloading image from S3: {error_code} - {error_message}')
        return jsonify({'error': f'Error downloading image from S3: {error_code} - {error_message}'}), 500
    #Predicts the objects in the image
    run(
        weights='yolov5s.pt',
        data='data/coco128.yaml',
        source=original_img_path,
        project='static/data',
        name=prediction_id,
        save_txt=True
    )

    logger.info(f'prediction: {prediction_id}/{original_img_path}. done')
    predicted_img_path = Path(f'static/data/{prediction_id}/{original_img_path}')
    predicted_image_name = f'{img_name[:-4]}_predicted.jpg'

    predicted_image_s3_path = f'static/data/{prediction_id}/{predicted_image_name}'
    # Upload the predicted image to S3
    try:
        s3_yolo.upload_file(str(predicted_img_path), bucket_name, predicted_image_s3_path)
        logger.info(f'Predicted image uploaded to S3. S3 path: {predicted_image_s3_path}')
    except botocore.exceptions.ClientError as e:
        error_code = e.response.get('Error', {}).get('Code')
        error_message = e.response.get('Error', {}).get('Message')
        logger.error(f'Error uploading predicted image to S3: {error_code} - {error_message}')
        return jsonify({'error': f'Error uploading predicted image to S3: {error_code} - {error_message}'}), 500
        
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
            'prediction_id': str(prediction_id),
            'original_img_path': original_img_path,
            'predicted_img_path': str(predicted_img_path),
            'labels': labels,
            'time': time.time()
        }
        # Store the prediction_summary in MongoDB
        try:
            #client = MongoClient("mongodb://mongo1:27017/")
            client = MongoClient("mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0")

            db = client["mymongodb"]
            collection = db["prediction"]
            result = collection.insert_one(prediction_summary)
            inserted_id = result.inserted_id
            logger.info(f"Inserted document with ID: {inserted_id}")
            prediction_summary['_id'] = str(inserted_id)
            return jsonify(prediction_summary)
        except Exception as e:
            # Handle exceptions and log the error
            logger.error(f"Error occurred while storing prediction_summary in MongoDB: {e}")
            traceback.print_exc()
            return jsonify({'error': 'Failed to store prediction_summary in MongoDB'}), 500
    else:
        return jsonify({'error': f'prediction: {prediction_id}/{original_img_path}. prediction result not found'}), 404


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8081)