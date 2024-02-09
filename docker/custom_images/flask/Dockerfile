FROM python:3.8

WORKDIR /app

COPY . /app

RUN apt update
RUN apt install nano

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
