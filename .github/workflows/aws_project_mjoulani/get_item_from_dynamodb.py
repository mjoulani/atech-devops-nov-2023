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
    {
        "class": "person",
        "cx": 0.0770833,
        "cy": 0.673675,
        "height": 0.0603291,
        "width": 0.0145833
    },
    {
        "class": "traffic light",
        "cx": 0.134375,
        "cy": 0.577697,
        "height": 0.0329068,
        "width": 0.0104167
    },
    {
        "class": "potted plant",
        "cx": 0.984375,
        "cy": 0.778793,
        "height": 0.095064,
        "width": 0.03125
    },
    {
        "class": "stop sign",
        "cx": 0.159896,
        "cy": 0.481718,
        "height": 0.0859232,
        "width": 0.053125
    },
    {
        "class": "car",
        "cx": 0.130208,
        "cy": 0.734918,
        "height": 0.201097,
        "width": 0.108333
    },
    {
        "class": "bus",
        "cx": 0.285417,
        "cy": 0.675503,
        "height": 0.140768,
        "width": 0.0729167
    }
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
    
prediction_id = "7be86932-9a5a-4b17-91e0-7419eb061705"
# Prediction ID to retrieve
prediction_id_to_retrieve = prediction_id

# Retrieve the item from the DynamoDB table
try:
    response = dynamodb_client.get_item(
        TableName=table_name,
        Key={
            'prediction_id': {'S': prediction_id_to_retrieve}
        }
    )
    # Check if the item was found
    if 'Item' in response:
        item = response['Item']
        print("Item retrieved successfully:")
        print(item)
    else:
        print("Item not found.")
except Exception as e:
    print("Error retrieving item:", e)
