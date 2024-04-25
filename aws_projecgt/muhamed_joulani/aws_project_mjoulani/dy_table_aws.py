import boto3
import json
import uuid
import time

# Generate unique IDs
prediction_id = str(uuid.uuid4())
chat_id = "6475767"

# Define paths and labels
original_img_path = "usr/scr/app"
predicted_img_path = "data/images/street.jpeg"
labels = [
      {'bus' : '3','car' : 'five' , 'house' : 'three'}       
    ]

# Convert labels to the format expected by DynamoDB
labels_dynamodb_format = [{'M': {k: {'N' if isinstance(v, (int, float)) else 'S': str(v)} for k, v in item.items()}} for item in labels]

# Get current time
current_time = str(time.time())

# Prediction summary dictionary
prediction_summary = {
    'prediction_id': prediction_id,
    'original_img_path': original_img_path,
    'predicted_img_path': predicted_img_path,
    'labels': labels_dynamodb_format,  # Use the converted labels format
    'chat_id': chat_id,
    'time': current_time
}

# Initialize a DynamoDB client using boto3
dynamodb_client = boto3.client('dynamodb', region_name='us-west-1')

# Define the table name
table_name = 'prediction_summary'

# Store the prediction summary in the DynamoDB table
try:
    response = dynamodb_client.put_item(
        TableName=table_name,
        Item={
            'prediction_id': {'S': prediction_id},
            'original_img_path': {'S': original_img_path},
            'predicted_img_path': {'S': predicted_img_path},
            'labels': {'L': labels_dynamodb_format},  # Use the converted labels format
            'chat_id': {'S': chat_id},
            'time': {'N': current_time}
        }
    )
    print("Item stored successfully.")
except Exception as e:
    print("Error storing item:", e)




