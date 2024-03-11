import json
import boto3
import telebot
from loguru import logger
import os
import requests
import time
from telebot.types import InputFile

pixabay_token = os.environ['PIXABAY_TOKEN']

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


def get_photo(param:str):
    param.replace(" ", "")
    url = f"https://pixabay.com/api/?key={pixabay_token}&q={param[8:].lower()}&image_type=photo"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            first_large_image_url = ""
            for hit in data["hits"]:
                if "largeImageURL" in hit:
                    logger.info(f"check {hit['largeImageURL']}")
                    first_large_image_url = hit["largeImageURL"]
                    break
            if first_large_image_url:
                return first_large_image_url
            else:
                logger.info("No images found.")
                return "No images found."
        else:
            logger.error(f"Failed to fetch data: HTTP Status Code {response.status_code}")
            return f"Error: Unable to access Pixabay API, received status code {response.status_code}"
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        return "Error: An issue occurred while attempting to fetch the photo."


class ObjectDetectionBot(Bot):

    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):

            # TODO download the user photo (utilize download_user_photo)
            photo_path = self.download_user_photo(msg)
            photo_key = os.path.basename(photo_path)
            # TODO upload the photo to S3
            s3 = boto3.client('s3')
            s3.upload_file(photo_path, "hamad-bucket-docker-project", photo_key)

            print(f"Photo uploaded successfully to S3 bucket: {'hamad-bucket-docker-project'} with key: {photo_key}")

            # TODO send a request to the `yolo5` service for prediction
            url = "http://yolo5:8081/predict"
            params = {"imgName": photo_key}
            headers = {"Content-Type": "application/json", "Accept": "application/json"}
            try:
                response = requests.post(url, params=params, headers=headers)
                # Handle response
            except requests.exceptions.RequestException as e:
                print("Error:", e)

            data = response.json()
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
        elif msg["text"].lower().startswith("pixabay:"):
            try:
                image_url = get_photo(msg['text'])
                if image_url.startswith("http"):  # Simple check to ensure it's a URL
                    logger.info(f" ###############{msg}")
                    self.send_text(msg['chat']['id'], f"Image URL: {image_url}")
                else:
                    self.send_text(msg['chat']['id'], "Failed to fetch image from Pixabay.")
            except Exception as e:
                logger.error(f"Cannot get photo: {e}")
                self.send_text(msg['chat']['id'], "An error occurred while fetching the photo.")

        else:
            logger.info("helllloooooooo")
            super().handle_message(msg)
