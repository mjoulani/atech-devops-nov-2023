import flask
from flask import request
from loguru import logger
import os
from bot import ObjectDetectionBot, Bot, QuoteBot
import requests
import json
import time

app = flask.Flask(__name__)

TELEGRAM_TOKEN = '6671531875:AAG0nnI0XX_kneDgsOXNfclJi0V0tpuGwBU'
#TELEGRAM_APP_URL = 'ald-aws-muh-1294285603.us-west-1.elb.amazonaws.com'
#TELEGRAM_APP_URL = 'ald-aws-muh-1294285603.us-west-1.elb.amazonaws.com/TELEGRAM_TOKEN/'
TELEGRAM_APP_URL = f'https://muh-aws-alb-1133477302.us-west-1.elb.amazonaws.com/'



#certificate_path = 'C:\\atech-devops-nov-2023\\.github\\workflows\\aws_project\\polybot\\cert.pem'

#TELEGRAM_APP_URL = 'muh-lbn-1573769404.us-west-1.elb.amazonaws.com'


logger.info(f"TELEGRAM_TOKEN: {TELEGRAM_TOKEN}")
logger.info(f"TELEGRAM_APP_URL: {TELEGRAM_APP_URL}")


@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    #req = request.get_json()
    #bot.handle_message(req['message'])
    #return 'Ok'

    try:
        print(f'TELEGRAM_TOKEN********req: {TELEGRAM_TOKEN}')
        req = request.get_json()
        print(f"Incoming JSON: {req}")
        bot.handle_message(req['message'])
        return 'Ok'
    except Exception as e:
        print(f"Exception: {e}")
        print(f"Incoming JSON: {req}")
        logger.info(f"TELEGRAM_TOKEN: {TELEGRAM_TOKEN}")
        logger.info(f"TELEGRAM_APP_URL: {TELEGRAM_APP_URL}")
        #bot.handle_message(req['message'])
        return  'Ok'#'Internal Server Error', 500


if __name__ == "__main__":
    #bot = Bot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    #bot = QuoteBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    #bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL,  certificate_path)
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)


    app.run(host='0.0.0.0', port=8443)













