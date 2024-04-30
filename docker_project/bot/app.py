#from telegram import Bot
import os
from flask import request
import flask
from botocore.exceptions import ClientError
from loguru import logger
from dotenv import load_dotenv
from bot import ObjectDetectionBot, Bot ,QuoteBot
import requests


load_dotenv()
TELEGRAM_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')

def get_ngrok_url():
    try:
        req = requests.get("http://ngrok:4040/api/tunnels")
        req.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)

        data = req.json()  # Parse JSON response
        tunnels = data.get("tunnels", [])
        for tunnel in tunnels:
            if "public_url" in tunnel:
                return tunnel["public_url"]

        print("No ngrok URL found in the response.")
    except requests.RequestException as e:
        print(f"Error: {e}")

app = flask.Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return 'Ok'

@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    try:
        bot.handle_message(req['message'])
    except KeyError:
        print("Message key not found in the request.")
    return 'Ok'


if __name__ == "__main__":
    TELEGRAM_APP_URL = get_ngrok_url()
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    app.run(host='0.0.0.0', port=8443)
