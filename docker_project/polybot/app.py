import flask
from flask import request
import os
from bot import ObjectDetectionBot

app = flask.Flask(__name__)

def read_secret(secret_name):
    secret_path = f"/run/secrets/{secret_name}"
    try:
        with open(secret_path, "r") as secret_file:
            return secret_file.read().strip()
    except FileNotFoundError:
        print(f"Secret file for {secret_name} not found.")
        return None


TELEGRAM_TOKEN = read_secret("telegram_token")
TELEGRAM_APP_URL = os.environ['TELEGRAM_APP_URL']

@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)
    app.run(host='0.0.0.0', port=8443)
