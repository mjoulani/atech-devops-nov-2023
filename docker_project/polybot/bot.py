import json
import requests
import telebot
from loguru import logger
import os
import time
import boto3
from telebot.types import InputFile

class Bot:

    def __init__(self, token, telegram_chat_url):
        print(telegram_chat_url)
        print(token)

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

        self.telegram_bot_client.send_photo(chat_id,InputFile(img_path))

    def handle_message(self, msg):
        """Bot Main message handler"""
        logger.info(f'Incoming message: {msg}')
        if 'text' in msg:
            self.send_text(msg['chat']['id'], f'Your original message: {msg["text"]}')
        else:
            self.send_text(msg['chat']['id'], "Sorry, I couldn't process your message.")


class QuoteBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if msg["text"] != 'Please don\'t quote me':
            self.send_text_with_quote(msg['chat']['id'], msg["text"], quoted_msg_id=msg["message_id"])


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        # logger.info(f'Incoming message: {msg}')
        if self.is_current_msg_photo(msg):
            # TODO download the user photo (utilize download_user_photo)
            photo_path = self.download_user_photo(msg)
            photo_key = os.path.basename(photo_path)

            # TODO upload the photo to S3
            s3 = boto3.client('s3')
            s3.upload_file(photo_path, "oferbakria" , photo_key)

            print(f"Photo uploaded successfully to S3 bucket: {'oferbakria'} with key: {photo_key}")

            # TODO send a request to the `yolo5` service for prediction
            url = "http://yolo5:8081/predict"
            params = {"imgName": photo_key}
            headers = {"Content-Type": "application/json", "Accept": "application/json"}
            try:
                response = requests.post(url, params=params , headers=headers)
                # Handle response
            except requests.exceptions.RequestException as e:
                print("Error:", e)
            

            data = response.json()
            logger.info(f'data\n\n{data}')

            # Initialize a dictionary to store counts of each class
            class_counts = {}
            # Iterate through the labels and count occurrences of each class
            for item in data['labels']:
                class_name = item['class']
                if class_name in class_counts:
                    class_counts[class_name] += 1
                else:
                    class_counts[class_name] = 1


            class_counts_string = ""
            for class_name, count in class_counts.items():
                class_counts_string += f"{class_name}: {count}\n"
                
            # TODO send results to the Telegram end-user
            self.send_text(msg['chat']['id'], f'Your photo contains : \n {class_counts_string}')

        elif self.custom_startswith(msg["text"], "pixabay:"):
            # TODO download the user photo (utilize download_user_photo)
            obj=msg["text"][len("pixabay:"):]
            url2 = f"http://pixabay:8082/getImage?imgName={obj}"
            data2 = requests.get(url2).content
            self.send_text(msg['chat']['id'], f'Your Photo from Pixabay API :{data2} \n')
        else:
            super().handle_message(msg)
    
    def custom_startswith(self,s, prefix):
        return s[:len(prefix)] == prefix


