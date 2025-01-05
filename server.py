import os
from dotenv import load_dotenv
import boto3
import json
from botocore.exceptions import ClientError

load_dotenv()

AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = 'us-east-1'
MODEL_ID = "mistral.mistral-7b-instruct-v0:2"
prompt = "Provide output strictly as JSON: {name,statement}. You are Delano. Your task is to speak about any one of the given topics in a few words. Choose a topic randomly from the following list: ['List innovative farming methods and how they work', 'How is food security handled for settlements', 'The battle against contaminated soil and methods']. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic."


brt = boto3.client("bedrock-runtime", 
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION)


native_request = {
    "prompt": prompt,
    "max_tokens": 512,
    "temperature": 1,
    "top_p": 1
}
body = json.dumps(native_request)


# response = brt.invoke_model(modelId=MODEL_ID, body=body.encode())
# response_body = json.loads(response['body'].read())
# print(response_body)

# Stream the response
streaming_response = brt.invoke_model_with_response_stream(modelId=MODEL_ID, body=body.encode())

for event in streaming_response['body']:
    chunk = json.loads(event['chunk']['bytes'])
    if 'outputs' in chunk:
        output = chunk['outputs'][0]
        print(output['text'], end="")
    
    if 'amazon-bedrock-invocationMetrics' in chunk:
        metrics = chunk['amazon-bedrock-invocationMetrics']
        print("\nmetrics", metrics)