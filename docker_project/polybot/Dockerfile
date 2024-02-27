FROM python:3.8
# Create a directory and set it as the working directory
WORKDIR /app     
# Copy the current directory contents into the container at /app
COPY . /app
RUN pip install -r requirements.txt

CMD ["python3", "app.py"]
