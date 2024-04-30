import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
import boto3
import json
from botocore.exceptions import NoCredentialsError

class Bot:

    def __init__(self, token, telegram_chat_url):
        # create a new instance of the TeleBot class.
        # all communication with Telegram servers are done using self.telegram_bot_client
        self.telegram_bot_client = telebot.TeleBot(token)

        # remove any existing webhooks configured in Telegram servers
        self.telegram_bot_client.remove_webhook()
        time.sleep(0.5)

        # set the webhook URL
        self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', timeout=60,certificate=open('abed22.pem', 'rb'))

        logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')

    def send_text(self, chat_id, text):
        self.telegram_bot_client.send_message(chat_id, text)

    def send_text_aut(self, msg):
        if msg['text'] == '/menu':
                self.telegram_bot_client.send_message(
                    msg['chat']['id'],
                    text="""Welcome to our project .
                        you can send : 
                        1. /start  
                        2./end  
                        3./menu  
                        Or send me a photo and I will try to predict the objects in your image""")

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
            raise RuntimeError(f'Message content of type \'photo\' expected')

        file_info = self.telegram_bot_client.get_file(msg['photo'][-1]['file_id'])
        data = self.telegram_bot_client.download_file(file_info.file_path)
        folder_name = file_info.file_path.split('/')[0]

        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        with open(file_info.file_path, 'wb') as photo:
            photo.write(data)

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
        self.send_text(msg['chat']['id'], f'Your original message: {msg["text"]}')


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):

        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):
            photo_path = self.download_user_photo(msg)

            # TODO upload the photo to S3
            s3_bucket_name = 'gz.abed'
            s3_object_key = f'{os.path.basename(photo_path)}'
            s3_client = boto3.client('s3')
            s3_client.upload_file(photo_path, s3_bucket_name, s3_object_key)
            
            # # TODO send a job to the SQS queue
            sqs_queue_url = 'https://sqs.eu-central-1.amazonaws.com/933060838752/Abed2Queue'
            sqs_client = boto3.client('sqs',region_name='eu-central-1')
            message_body = {
                'image_name': s3_object_key,
                'chat_id': msg['chat']['id']  # Assuming sender_id exists in your message object
            }
            response = sqs_client.send_message(
                QueueUrl=sqs_queue_url,
                MessageBody=json.dumps(message_body)
            )
        
            logger.info(f'Message sent to SQS queue: {response}')
            # TODO send message to the Telegram end-user (e.g. Your image is being processed. Please wait...)
            self.send_text(chat_id=msg['chat']['id'], text="Your image is being processed. Please wait...")
            
        elif msg['text'] == '/end':
                self.telegram_bot_client.send_message(msg['chat']['id'], text='Thank you and never come back!!!')
                time.sleep(2)
                self.telegram_bot_client.send_message(msg['chat']['id'], text='Hey, I`m Kidding, I`m here for you, come back whenever you want ')
        elif msg['text'] == '/start':
                self.telegram_bot_client.send_message(msg['chat']['id'], text='Hi, my name is Yolobot.\n \
                                                    Please send me a photo and I will try to predict the objects in your image')
        elif msg['text'] == '/menu':
                self.telegram_bot_client.send_message(
                    msg['chat']['id'],
                    text="""Welcome to our project .
                        you can send : 
                        1. /start  
                        2./end  
                        3./menu  
                        Or send me a photo and I will try to predict the objects in your image""")
        else:
            self.telegram_bot_client.send_message(msg['chat']['id'], text='Opss but I dont unsderstand what that means " {} ".\n Try using these command for help: /menu'.format(msg["text"]))    
    