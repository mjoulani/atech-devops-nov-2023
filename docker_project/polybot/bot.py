from functools import reduce
import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
import boto3
import requests

images_bucket = os.environ['BUCKET_NAME']

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

    @staticmethod
    def is_current_msg_photo(msg):
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


class QuoteBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if msg["text"] != 'Please don\'t quote me':
            self.send_text_with_quote(msg['chat']['id'], msg["text"], quoted_msg_id=msg["message_id"])


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):
            pass
            # TODO download the user photo (utilize download_user_photo)
            file_path = self.download_user_photo(msg)
            image_name = file_path.split("/")[-1]
            print(image_name)
            # TODO upload the photo to S3
            self.upload_file_to_s3(image_name, file_path)
            # TODO send a request to the `yolo5` service for prediction
            res = self.send_request_to_yolo(image_name)
            if res.status_code != 200:
                self.send_text(msg['chat']['id'], "Error with Identified Objects in Photo")
                return
            result_string = self.get_result_from_response(res.json())
            # TODO send results to the Telegram end-user
            self.send_text(msg['chat']['id'],result_string)
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

    def send_request_to_yolo(self, image_name):
        url = 'http://yolo_app:8081/predict'
        params = {
            'imgName': image_name
        }
        response = requests.post(url, params=params, data={})
        return response

    def get_result_from_response(self, res):
        labels = res['labels']
        result = {}
        for label in labels:
            label_name = label['class']
            value = result.get(label_name)
            if value is None:
                result[label_name] = 1
            else:
                result[label_name] = value + 1

        result_string = reduce(lambda acc, item: acc + f"{item[0]} {item[1]}\n", result.items(), "Detected objects :\n")
        return result_string



