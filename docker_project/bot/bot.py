import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
import boto3
from botocore.exceptions import NoCredentialsError
import requests

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


class QuoteBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if msg["text"] != 'Please don\'t quote me':
            self.send_text_with_quote(msg['chat']['id'], msg["text"], quoted_msg_id=msg["message_id"])


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')
        if self.is_current_msg_photo(msg):
            try:
                # TODO download the user photo (utilize download_user_photo)
                photo_path = self.download_user_photo(msg)
                # TODO upload the photo to S3
                s3_bucket_name = 'gz.abed' ####need to do#######
                s3_object_key = f'{os.path.basename(photo_path)}'
                s3_client = boto3.client('s3')
                s3_client.upload_file(photo_path, s3_bucket_name, s3_object_key)
                
                # TODO send a request to the `yolo5` service for prediction
                img_name = self.download_user_photo(msg).split('/')[1]
                response = requests.post(url=f'http://yoloapp:8081/predict?imgName={img_name}')
                
                # #TODO send results to the Telegram end-user
                print(response.status_code)
                if response.status_code == 200:
                        detection_results = response.json()
                        # Count the occurrences of each type of object
                        object_counts = {}
                        for obj in detection_results['labels']:
                            obj_class = obj['class']
                            object_counts[obj_class] = object_counts.get(obj_class, 0) + 1
                        # Create a string with counts for each type of object
                        object_counts_string = "\n".join([f"{obj_class}: {count}" for obj_class, count in object_counts.items()])
                        self.telegram_bot_client.send_message(msg['chat']['id'], text=f"Object counts:\n{object_counts_string}")
                        self.telegram_bot_client.send_message(msg['chat']['id'],
                        text="""Welcome to our project
                        you can send : 
                        1. /start  
                        2./end  
                        3./menu  
                        Or send me a photo and I will try to predict the objects in your image""".format(left_align=":<100")
                        )
                else:
                    error_message = f'Error from yolo5 service: {response.text}'
                    self.send_text(msg['chat']['id'], error_message)

            except NoCredentialsError:
                logger.error("Credentials not available for S3. Make sure to configure AWS credentials.")
            except Exception as e:
                logger.error(f"An error occurred: {str(e)}")

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