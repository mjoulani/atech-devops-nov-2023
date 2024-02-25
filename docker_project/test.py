import pymongo

# Connect to MongoDB
client = pymongo.MongoClient("mongodb://mongo1:27017/")
db = client["mongodb"]
collection = db["prediction"]

# Query the collection to retrieve the data
cursor = collection.find()

# Print the retrieved data
for document in cursor:
    print(document)

# Close the MongoDB connection
client.close()