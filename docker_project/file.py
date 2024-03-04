import json
import requests
import flask
from flask import request
import os
import requests 


app = flask.Flask(__name__)

# PIXABAY_TOKEN = os.environ['TELEGRAM_TOKEN']

@app.route('/getImage', methods=['GET'])
def getimg():
    img_name = request.args.get('imgName')
    url=f"https://pixabay.com/api/?key={PIXABAY_TOKEN}&q={img_name}&image_type=photo&pretty=true"
    data = json.loads(requests.get(url).content)
    first_large_image_url = ""
    for hit in data["hits"]:
        if "largeImageURL" in hit:
            first_large_image_url = hit["largeImageURL"]
            break
    return first_large_image_url

@app.route('/', methods=['GET'])
def index():
    return 'Ok'

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8082)


