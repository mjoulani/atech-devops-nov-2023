import telebot
from loguru import logger
import os
import time
import boto3
import json
from telebot.types import InputFile
import uuid

images_bucket = "abed-skout-aws-project-buket"
queue_url = "https://sqs.ap-northeast-2.amazonaws.com/933060838752/abed-skout-sqs-aws-project.fifo"


class Bot:

    def __init__(self, token, telegram_chat_url):
        # create a new instance of the TeleBot class.
        # all communication with Telegram servers are done using self.telegram_bot_client
        self.telegram_bot_client = telebot.TeleBot(token)

        # remove any existing webhooks configured in Telegram servers
        self.telegram_bot_client.remove_webhook()
        time.sleep(0.5)

        # set the webhook URL
        self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', timeout=60)

        logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')

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

    def upload_file_to_s3(self, object_name, image_path):
        # Upload the file
        s3_client = boto3.client('s3')
        print("image_path is " + str(image_path))
        try:
            s3_client.upload_file(image_path, images_bucket, object_name)
            print(f"File {image_path} uploaded to {images_bucket}/{object_name}")
            return True
        except RuntimeError:
            print("Credentials not available")
            return False
        except Exception as e:
            print(f"Error: {e}")
            return False

    def send_job_to_sqs(self, chat_id, image_name):
        message_deduplication_id = str(uuid.uuid4())
        sqs = boto3.client('sqs', region_name='ap-northeast-2')
        msg_payload = {'chat_id': chat_id, 'image_name': image_name}
        message_body = json.dumps(msg_payload)
        response = sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=message_body,
            MessageGroupId=str(chat_id),
            MessageDeduplicationId=message_deduplication_id  # Explicitly provide MessageDeduplicationId
        )
        print(f'Message ID: {response["MessageId"]}')


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):
            photo_path = self.download_user_photo(msg)
            image_name = photo_path.split("/")[-1]
            # TODO upload the photo to S3
            self.upload_file_to_s3(image_name, photo_path)
            # TODO send a job to the SQS queue
            self.send_job_to_sqs(msg['chat']['id'],image_name)
            # TODO send message to the Telegram end-user (e.g. Your image is being processed. Please wait...)
            self.send_text(msg['chat']['id'],"Your image is being processed. Please wait...")
