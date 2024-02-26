from datetime import datetime

import pymongo

# Connect to MongoDB
client = pymongo.MongoClient("mongodb://mongo1:27017/")
db = client["mongodb"]
collection = db["prediction"]

# Create a sample document to insert
sample_document = {
    "prediction_id": "12345",
    "original_img_path": "sample_image.jpg",
    "predicted_img_path": "predicted_image.jpg",
    "labels": [
        {"class": "label_1", "cx": 10, "cy": 20, "width": 30, "height": 40},
        {"class": "label_2", "cx": 50, "cy": 60, "width": 70, "height": 80},
    ],
    "time": datetime.now()
}

# Insert the document into the collection
inserted_id = collection.insert_one(sample_document).inserted_id

# Query the collection to retrieve the data
cursor = collection.find()

# Print the retrieved data
for document in cursor:
    print(document)

# Close the MongoDB connection
client.close()