import boto3

# SQS queue name
QUEUE_NAME = 'oferbakria-queue'

# Create an SQS client
sqs = boto3.client('sqs', region_name="eu-west-1")

# Get the queue URL by its name
queue_url = 'https://sqs.eu-west-1.amazonaws.com/933060838752/oferbakria-queue'


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
message = "Hello Ofer bakria 3!"
send_message_to_sqs(message)
