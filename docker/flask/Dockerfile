FROM python:3.8.12-slim-buster
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY . .

CMD ["python3", "app.py"]
 