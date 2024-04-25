import os
import boto3

# Define the bucket name, file name, and download path
bucket_name = 'mjoulani-bucket'
file_name = r"static/data/fa80fe54-d0ed-49e5-9b48-54b95585c620/file_117_predicted.jpg"
download_path = r"C:\atech-devops-nov-2023\.github\workflows\aws_project_mjoulani\yolo5"

# Extract the file name from the file path
file_name_only = os.path.basename(file_name)

# Check if the download path directory exists, if not create it
if not os.path.exists(download_path):
    os.makedirs(download_path)

# Construct the full file path
file_path = os.path.join(download_path, file_name_only)
print(f"file_path = {file_path}")

# Create an S3 client
s3 = boto3.client('s3')

# Download the file from the S3 bucket to the specified path
try:
    s3.download_file(bucket_name, file_name_only, file_path)
    print(f"File downloaded successfully to: {file_path}")
except Exception as e:
    print(f"Error downloading file: {e}")
