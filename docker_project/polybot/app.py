import flask
from flask import request
from loguru import logger
import os
from bot import ObjectDetectionBot, Bot, QuoteBot
import requests
import json
import time

app = flask.Flask(__name__)

#TELEGRAM_TOKEN = '6671531875:AAG0nnI0XX_kneDgsOXNfclJi0V0tpuGwBU'
#TELEGRAM_APP_URL = 'https://64e5-93-173-73-255.ngrok-free.app' 
TELEGRAM_TOKEN1 = os.environ.get('TELEGRAM_TOKEN')
print("the input from outside environment TELEGRAM_TOKEN_1 =  ",TELEGRAM_TOKEN1)
if not TELEGRAM_TOKEN1:
    print("Error: TELEGRAM_TOKEN environment variable is not set.")
else:
    try:
        with open(TELEGRAM_TOKEN1, "r") as file:
            TELEGRAM_TOKEN = file.read().strip()
        print(f"TELEGRAM_TOKEN: {TELEGRAM_TOKEN}")
    except FileNotFoundError:
        print(f"Error: File not found - {TELEGRAM_TOKEN}")
        exit
    except Exception as e:
        print(f"Error: {e}")
        exit
    


TELEGRAM_APP_URL = os.environ.get('TELEGRAM_APP_URL')
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

    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)


    app.run(host='0.0.0.0', port=8443)
