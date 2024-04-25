import boto3
import json
import os

# Define the queue name and region
queue_name = 'muh_sqs'  # Replace 'muh_sqs' with your actual SQS queue name
region_name = 'us-west-1'

# Create an SQS client
sqs_client = boto3.client('sqs', region_name=region_name)

# Get the URL of the queue
response = sqs_client.get_queue_url(QueueName=queue_name)
sqs_url = response['QueueUrl']

# Receive a message from the queue
response1 = sqs_client.receive_message(QueueUrl=queue_name, MaxNumberOfMessages=1, WaitTimeSeconds=5)
print("Received message:")
print(response1)

# Check if there are messages
if 'Messages' in response1:
    message = response1['Messages'][0]['Body']
    message_list = json.loads(message)

    # Extract elements from the message
    file_name = message_list[0]  # First element of the list
    chat_id = message_list[1]     # Second element of the list

    # Download the file from S3
    bucket_name = 'mjoulani-bucket'  # Replace 'mjoulani-bucket' with your actual bucket name
    original_img_path = r"C:\atech-devops-nov-2023\.github\workflows\aws_project_mjoulani"  # Change this to your desired local path

    s3 = boto3.client('s3')
    s3.download_file(bucket_name, file_name, os.path.join(original_img_path, file_name))
    print(f"File '{file_name}' downloaded successfully.")
else:
    print("No messages in the queue.")
