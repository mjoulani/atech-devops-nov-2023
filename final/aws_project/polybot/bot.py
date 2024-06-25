import json
import requests
import telebot
from loguru import logger
import os
import time
import boto3
from telebot.types import InputFile
from botocore.exceptions import ClientError
import io
from kubernetes import client, config
import base64

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


        # with open('YOURPUBLIC.pem', 'r') as file:
        #   pem_contents = file.read()
        #   print(pem_contents)
        # # set the webhook URL
        # #self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', timeout=60)
        # self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', certificate=open('YOURPUBLIC.pem', 'r'))
        # logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')
        


        # session = boto3.session.Session()
        # client = session.client(
        #     service_name='secretsmanager',
        #     region_name="eu-west-1"
        # )
        # secret_response  = client.get_secret_value(
        #     SecretId="oferbakria_certificate"
        # )
        # pem_contents = secret_response['SecretString']
        # print("PEM Contents:", pem_contents)
        # # Parse the JSON
        # data = json.loads(pem_contents)

        # # Extract the certificate value
        # cert_value = data['poly_cert']

        # # Write the certificate to a file
        # with open('YOURPUBLIC.pem', 'w') as cert_file:
        #     cert_file.write(cert_value)

        # self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', certificate=open('YOURPUBLIC.pem', 'r'))
        # logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')

        namespace = "oferbakria"  # Replace with your namespace
        secret_name = "tls-secret-oferbakria"  # Replace with your secret name

        secret_data = self.get_k8s_secret(namespace, secret_name)
        if secret_data:
            for key, value in secret_data.items():
                print(f"{key}: {value}")
            pem_contents = base64.b64decode(secret_data["tls.crt"]).decode("utf-8")
            print(pem_contents)

        # Example of using the PEM content (e.g., sending it to a webhook)
        pem_file = io.StringIO(pem_contents)
        self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', certificate=pem_file)

    def  get_k8s_secret(namespace, secret_name):
        # Load kubeconfig from default location or specified path
        config.load_kube_config()  # Use config.load_incluster_config() if running inside a pod

        # Create an instance of the CoreV1Api
        v1 = client.CoreV1Api()

        try:
            # Retrieve the secret
            secret = v1.read_namespaced_secret(secret_name, namespace)
            return secret.data
        except client.exceptions.ApiException as e:
            print(f"Exception when calling CoreV1Api->read_namespaced_secret: {e}")
            return None


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
            self.send_text(msg['chat']['id'], f'3 :Your original message: {msg["text"]}')
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
         
            message = {
                'image': photo_key,
                'chat_id': msg['chat']['id']
            }
            
            self.send_message_to_sqs(json.dumps(message))

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
        
    def send_message_to_sqs(self,message):
        # SQS queue name
        QUEUE_NAME = 'oferbakria_aws_sqs'
        
        # Create an SQS client
        sqs = boto3.client('sqs', region_name="eu-west-1")
        
        # Get the queue URL by its name
        queue_url = 'https://sqs.eu-west-1.amazonaws.com/933060838752/oferbakria_aws_sqs'
        try:
            response = sqs.send_message(
                QueueUrl=queue_url,
                MessageBody=message
            )
            print("Message successfully sent to SQS:", response['MessageId'])
        except Exception as e:
            print("Error sending message to SQS:", e)



