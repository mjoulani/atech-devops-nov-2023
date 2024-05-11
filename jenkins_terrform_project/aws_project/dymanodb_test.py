#for testing propose
import boto3
from decimal import Decimal

# Initialize DynamoDB resource
dynamodb_resource = boto3.resource('dynamodb', region_name='us-west-1')

# Assuming you have already created a table named 'prediction_summary'
table_name = 'prediction_summary'

# Get the DynamoDB table
table = dynamodb_resource.Table(table_name)

# Function to store data in DynamoDB
def store_data_in_dynamodb(data):
    # Store data in DynamoDB table
    table.put_item(Item=data)
    print("Data stored successfully.")

# Function to retrieve data from DynamoDB using prediction_id
def retrieve_data_from_dynamodb(prediction_id):
    # Retrieve item based on prediction_id
    response = table.get_item(Key={'prediction_id': prediction_id})

    # Check if the item exists
    if 'Item' in response:
        item = response['Item']
        print("Item found:")
        print(item)
    else:
        print("Item with the given prediction_id not found.")

# Data to be stored
data = {
    "prediction_id": "9a95126c-f222-4c34-ada0-8686709f6432",
    "original_img_path": "data/images/street.jpeg",
    "predicted_img_path": "static/data/9a95126c-f222-4c34-ada0-8686709f6432/street.jpeg",
    "labels": [
        {
            "class": "person",
            "cx": Decimal('0.0770833'),
            "cy": Decimal('0.673675'),
            "height": Decimal('0.0603291'),
            "width": Decimal('0.0145833')
        },
        {
            "class": "traffic light",
            "cx": Decimal('0.134375'),
            "cy": Decimal('0.577697'),
            "height": Decimal('0.0329068'),
            "width": Decimal('0.0104167')
        },
        {
            "class": "potted plant",
            "cx": Decimal('0.984375'),
            "cy": Decimal('0.778793'),
            "height": Decimal('0.095064'),
            "width": Decimal('0.03125')
        },
        {
            "class": "stop sign",
            "cx": Decimal('0.159896'),
            "cy": Decimal('0.481718'),
            "height": Decimal('0.0859232'),
            "width": Decimal('0.053125')
        },
        {
            "class": "car",
            "cx": Decimal('0.130208'),
            "cy": Decimal('0.734918'),
            "height": Decimal('0.201097'),
            "width": Decimal('0.108333')
        },
        {
            "class": "bus",
            "cx": Decimal('0.285417'),
            "cy": Decimal('0.675503'),
            "height": Decimal('0.140768'),
            "width": Decimal('0.0729167')
        }
    ],
    "time": Decimal('1692016473.2343626')
}

# Store data in DynamoDB
store_data_in_dynamodb(data)

# Retrieve data from DynamoDB using prediction_id
prediction_id_to_retrieve = "9a95126c-f222-4c34-ada0-8686709f6432"
retrieve_data_from_dynamodb(prediction_id_to_retrieve)




