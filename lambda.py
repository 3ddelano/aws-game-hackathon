import os
import boto3
import json
import time


MOCK_RESPONSE = False
AWS_REGION = 'us-east-1'
MODEL_ID = "mistral.mistral-large-2402-v1:0" 
brt = boto3.client("bedrock-runtime",  region_name=AWS_REGION, aws_access_key_id=os.environ['ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['SECRET_ACCESS_KEY'])

# Lambda handler function should be named 'lambda_handler' not 'lambda_handle'
def lambda_handler(event, context):
    try:
        # Lambda events come as dictionaries, no need to parse event['prompt'] as JSON
        data = json.loads(event['body'])
        
        if not data or 'prompt' not in data:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'prompt' in request body"})
            }

        input_value = data['prompt']
        prompt = input_value + ". Strictly respond in plain text, limited to 4 sentences."
        native_request = {
            "prompt": prompt,
            "temperature": 0.6,
            "top_p": 0.9
        }
        if MOCK_RESPONSE:
            time.sleep(3)
            return {
                "statusCode": 200,
                "body": json.dumps({"output": "Mocked resposne. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris lorem ligula, convallis a massa nec, lacinia commodo lectus. Praesent quis felis viverra, faucibus nisi nec, ullamcorper magna. Phasellus ut augue ac tortor elementum euismod nec sed felis. Fusce ut arcu pretium massa gravida sodales non at diam. Donec non risus ipsum."})
            }
        print(f"Calling AWS bedrock: model={MODEL_ID}")
        start_time = time.time()
        brt_response = brt.invoke_model(modelId=MODEL_ID, body=json.dumps(native_request).encode())
        response_body = json.loads(brt_response['body'].read())
        print(f"Took={time.time() - start_time}, response_body={response_body}")
        output_value = response_body['outputs'][0]['text']

        return {
            "statusCode": 200,
            "body": json.dumps({"output": output_value})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"output": str(e)})
        }  # Return a JSON response for error handling in Lambda



