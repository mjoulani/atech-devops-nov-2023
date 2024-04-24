import boto3
import json
from botocore.exceptions import ClientError

def get_secret():
    secret_name = "muh_token"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        # Retrieve the secret value
        response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # Handle exceptions
        error_message = f"Failed to retrieve secret '{secret_name}' from Secrets Manager: {e}"
        raise ValueError(error_message) from None

    # Extract the secret string from the response
    if 'SecretString' in response:
        secret_string = response['SecretString']
    else:
        raise ValueError("Secret value not found in response.")

    # Parse the JSON string to extract the value associated with the key "muh_token"
    try:
        secret_value = json.loads(secret_string)['muh_token']
    except json.JSONDecodeError:
        raise ValueError("Failed to parse secret value as JSON.") from None

    return secret_value

# Example usage
if __name__ == "__main__":
    try:
        secret_value = get_secret()
        print(f"The secret value is: {secret_value}")
        # Your code goes here...
    except ValueError as ve:
        print(ve)
