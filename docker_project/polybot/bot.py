import telebot
import os
import time
import uuid
import requests
from botocore.exceptions import NoCredentialsError
from loguru import logger
from telebot.types import InputFile
import boto3
import json

bucket_name = os.environ['BUCKET_NAME']
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
            # TODO download the user photo (utilize download_user_photo)
            photo_path = self.download_user_photo(msg)
            # TODO upload the photo to S3
            image_id = self.upload_to_s3(photo_path, bucket_name)
            logger.info(f'Photo uploaded to S3')
            # TODO send a request to the `yolo5` service for prediction
            prediction_result = self.predict_with_yolo5(image_id)
            time.sleep(5)
            # TODO send results to the Telegram end-user
            response_data = json.loads(prediction_result)
            class_counts = {}
            for label in response_data['labels']:
                class_name = label['class']
                if class_name in class_counts:
                    class_counts[class_name] += 1
                else:
                    class_counts[class_name] = 1

            response = []
            for class_name, count in class_counts.items():
                response.append({'class': class_name, 'count': count})

            response_to_enduser = json.dumps(response)

            self.send_text(msg['chat']['id'], f'Prediction Result: {response_to_enduser}')
            image_id_new = image_id[:-4] + "_predicted.jpg"
            predict_img_path = photo_path.split('/')[0]
            final_image_predict_path = predict_img_path +"/"+ image_id_new

            s3 = boto3.client('s3')
            try:
                s3.download_file(bucket_name, image_id_new, final_image_predict_path)
                self.send_photo(msg['chat']['id'],final_image_predict_path)
            except Exception as e:
                logger.error(f"downloading predicted photo to S3 Failed: {e}")

    def upload_to_s3(self, local_path, bucket_name):
        s3 = boto3.client('s3')

        image_id = str(uuid.uuid4())
        image_id = f'{image_id}.jpeg'
        try:
            s3.upload_file(local_path, bucket_name, image_id)
            logger.info(f'Photo uploaded to S3. S3 URL: s3://{bucket_name}/{image_id}')

            return image_id
        except NoCredentialsError:
            logger.error("AWS credentials not available.")
            return None
        except Exception as e:
            logger.error(f"uploading photo to S3 Failed: {e}")
            return None

    def predict_with_yolo5(self, image_id):
        prediction_result = None
        logger.info(f'Sending Photo to yolo5, S3 URL: s3://{bucket_name}/{image_id}')
        base_url = "http://yolo5:8081"
        endpoint = "/predict"
        url = base_url + endpoint
        params = {'imgName': image_id}

        try:

            response = requests.post(url, params=params)

            if response.status_code == 200:
                prediction_result = response.json()
                logger.info(f'Response 200: ****{prediction_result}******/')

            else:
                print(f"Error: {response.status_code} - {response.text}")

        except requests.exceptions.RequestException as e:
            print(f"Error sending request: {e}")
        return prediction_result