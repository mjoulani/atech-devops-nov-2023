import boto3

# SQS queue name
QUEUE_NAME = 'Abed2Queue'

# Create an SQS client
sqs = boto3.client('sqs', region_name="eu-central-1")

# Get the queue URL by its name
queue_url = 'https://sqs.eu-central-1.amazonaws.com/933060838752/Abed2Queue'


# Send a message to the SQS queue
def send_message_to_sqs(message):
    try:
        response = sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=message
        )
        print("Message successfully sent to SQS:", response['MessageId'])
    except Exception as e:
        print("Error sending message to SQS:", e)


# Example usage of the function to send a message
message = "This was my first write here. "
send_message_to_sqs(message)
