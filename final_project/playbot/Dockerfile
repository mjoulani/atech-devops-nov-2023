FROM python:alpine
WORKDIR /usr/src/app
RUN pip install --upgrade pip
COPY app.py .
COPY bot.py .
COPY . .
COPY requirements.txt .
RUN pip install -r requirements.txt

# Set the environment variable
# ENV WEBHOOK_URL=https://try.atech-bot.click/
# ENV BUCKET_NAME=mjoulani-bucket
# ENV SQS_QUEUE_NAME=muh_sqs
# ENV REGION_NAME=us-east-1
EXPOSE 8080
CMD ["python","app.py"]