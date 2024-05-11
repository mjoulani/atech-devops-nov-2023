# generale skelton not for running the code which we run inside the folder EC2
import telebot
from loguru import logger
import os
import time
import boto3
from telebot.types import InputFile
import json

# bucket_name = os.environ['BUCKET_NAME']
# queue_name = os.environ['SQS_QUEUE_NAME']
# region_name = os.environ['REGION_NAME']

# logger.info(f'BUCKET NAME =  {bucket_name}')
# logger.info(f'QUEUE NAME =  {queue_name}')
# logger.info(f'REGION NAME =  {region_name}')

class Bot:

    def __init__(self, token, telegram_chat_url):
        # create a new instance of the TeleBot class.
        # all communication with Telegram servers are done using self.telegram_bot_client
        self.telegram_bot_client = telebot.TeleBot(token)

        # remove any existing webhooks configured in Telegram servers
        self.telegram_bot_client.remove_webhook()
        time.sleep(0.5)

        # set the webhook URL
        #cert_url = 'certificate.pem'
        cert_url = r'C:\atech-devops-nov-2023\.github\workflows\aws_project_mjoulani\certificate.pem'
        self.telegram_bot_client.set_webhook(
           url=f'{telegram_chat_url}/{token}/', 
           certificate=open(cert_url,'rb')
        )


        logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')

    def send_message_to_sqs(queue_name, region_name, message_body):
        # Create an SQS client
        sqs_client = boto3.client('sqs', region_name=region_name)

        # Get the URL of the queue
        response = sqs_client.get_queue_url(QueueName=queue_name)
        sqs_url = response['QueueUrl']

        # Send a message to the queue
        response = sqs_client.send_message(QueueUrl=sqs_url, MessageBody=message_body)

        return response
    
    def send_text(self, chat_id, text):
        self.telegram_bot_client.send_message(chat_id, text)

    def send_text_with_quote(self, chat_id, text, quoted_msg_id):
        self.telegram_bot_client.send_message(chat_id, text, reply_to_message_id=quoted_msg_id)

    def is_current_msg_photo(self, msg):
        return 'photo' in msg

    def download_user_photo(self, msg):
        """
        Downloads the photos that sent to the Bot to `photos` directory (should be existed)
        :return:
        """
        if not self.is_current_msg_photo(msg):
            # If the message does not contain a photo, send a response and return
            text = "Please upload a photo."
            self.send_text(msg['chat']['id'], text)
            return None 

        file_info = self.telegram_bot_client.get_file(msg['photo'][-1]['file_id'])
        data = self.telegram_bot_client.download_file(file_info.file_path)
        folder_name = file_info.file_path.split('/')[0]
        
       


        if not os.path.exists(folder_name):
            os.makedirs(folder_name)
            
         
        with open(file_info.file_path, 'wb') as photo:
            photo.write(data)
        photo_path = '/usr/scr/app/photos'

        return file_info.file_path

    def send_photo(self, chat_id, img_path):
        if not os.path.exists(img_path):
            raise RuntimeError("Image path doesn't exist")

        self.telegram_bot_client.send_photo(
            chat_id,
            InputFile(img_path)
        )

    def handle_message(self, msg):
        """Bot Main message handler"""
        logger.info(f'Incoming message: {msg}')
        if 'text' in msg:
            # If the message contains text, send a response based on the text
            self.send_text(msg['chat']['id'], f'Your original message: {msg["text"]}')
        elif 'photo' in msg:
            # If the message contains a photo, download and process the photo
            img_path = self.download_user_photo(msg)
            logger.info(f'Downloaded photo to {img_path}')
            # Process the photo...
        else:
            # If the message contains other types of content, handle it accordingly
            # For example, you can send a default response or ignore the message
            self.send_text(msg['chat']['id'], 'Unsupported message type')
            
    


class ObjectDetectionBot(Bot):
   def handle_message(self, msg):
        """Bot Main message handler"""
        logger.info(f'Incoming message: {msg}')
        img_path = self.download_user_photo(msg)
        if img_path:
            # Extract the directory and filename from img_path
            directory, filename = os.path.split(img_path)
            # Construct the new filename with 'e' prefix
            new_filename = 'e' + filename
            # Construct the new path with the renamed filename
            new_img_path = os.path.join(directory, new_filename)
            # Rename the file
            os.rename(img_path, new_img_path)
            # Update img_path with the new path
            img_path = new_img_path
            
            # Photo downloaded successfully, proceed with upload
            s3 = boto3.client('s3')
            bucket_name = 'mjoulani-bucket'
            queue_name = 'muh_sqs'  # Replace 'muh_sqs' with your actual SQS queue name
            region_name = 'us-west-1'
            message_body = json.dumps([os.path.basename(img_path),msg['chat']['id']])
            s3.upload_file(img_path, bucket_name, os.path.basename(img_path))
            logger.info(f'Uploaded photo to S3')
            response = self.send_message_to_sqs(queue_name, region_name, message_body)
            logger.info('The SQS response : {response}')
            temp = json.loads(message_body)
            text = f' Your image {temp[0]} is being processed. Please wait...'
            self.send_text(msg['chat']['id'], text)
        
        else:
            # Photo download failed, handle accordingly
            logger.info('Failed to download photo from the message.')
            # TODO upload the photo to S3
            # TODO send a job to the SQS queue
            # TODO send message to the Telegram end-user (e.g. Your image is being processed. Please wait...)
        