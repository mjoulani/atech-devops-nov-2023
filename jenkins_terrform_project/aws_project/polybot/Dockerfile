FROM python:alpine
WORKDIR /usr/src/app
RUN pip install --upgrade pip
COPY app.py .
COPY bot.py .
COPY . .
COPY requirements.txt .
RUN pip install -r requirements.txt

# Set the environment variable
ENV WEBHOOK_URL=https://muh-aws-alb-1133477302.us-west-1.elb.amazonaws.com/
ENV BUCKET_NAME=mjoulani-bucket
ENV SQS_QUEUE_NAME=muh_sqs
ENV REGION_NAME=us-west-1
EXPOSE 8443
CMD ["python","app.py"]
