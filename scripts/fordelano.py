import os
import boto3
import json
from botocore.exceptions import ClientError

aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
aws_region = 'us-east-1'

session = boto3.Session(
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)
brt = session.client("bedrock-runtime", "us-east-1")

model_id = "mistral.mistral-7b-instruct-v0:2"

prompt = "Provide output strictly as JSON: {name,statement}. You are Delano. Your task is to speak about any one of the given topics in a few words. Choose a topic randomly from the following list: ['List innovative farming methods and how they work', 'How is food security handled for settlements', 'The battle against contaminated soil and methods']. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic."

native_request = {
    "prompt": prompt,
    "max_tokens": 512,
    "temperature": 1,
    "top_p": 1
}

body = json.dumps(native_request)
response = brt.invoke_model(modelId=model_id, body=body.encode())
response_body = json.loads(response['body'].read())
print(response_body)

