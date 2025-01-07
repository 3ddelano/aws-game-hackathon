import os
from dotenv import load_dotenv
import boto3
import json
from botocore.exceptions import ClientError
from flask import Flask, request, jsonify

load_dotenv()

AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = 'us-east-1'
# MODEL_ID = "mistral.mistral-7b-instruct-v0:2"
MODEL_ID = "us.meta.llama3-3-70b-instruct-v1:0"
# prompt = "Provide output strictly as JSON: {name,statement}. You are Delano. Your task is to speak about any one of the given topics in a few words. Choose a topic randomly from the following list: ['List innovative farming methods and how they work', 'How is food security handled for settlements', 'The battle against contaminated soil and methods']. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic."

brt = boto3.client("bedrock-runtime", 
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION)

# # Stream the response
# streaming_response = brt.invoke_model_with_response_stream(modelId=MODEL_ID, body=body.encode())
# for event in streaming_response['body']:
#     chunk = json.loads(event['chunk']['bytes'])
#     if 'outputs' in chunk:
#         output = chunk['outputs'][0]
#         print(output['text'], end="")
    
#     if 'amazon-bedrock-invocationMetrics' in chunk:
#         metrics = chunk['amazon-bedrock-invocationMetrics']
#         print("\nmetrics", metrics)

app = Flask(__name__)
@app.route('/ai-response', methods=['POST'])
def post_ai_response():
    try:
        data = request.get_json()

        if not data or 'prompt' not in data:
            return jsonify({"error": "Missing 'prompt' in request body"}), 400

        input_value = data['prompt']

        prompt = input_value + "\n Respond only in plain text.\n\n"

        native_request = {
            "prompt": prompt,
            "max_gen_len": 100,
            "temperature": 1,
            "top_p": 1
        }

        brt_response = brt.invoke_model(modelId=MODEL_ID, body=json.dumps(native_request).encode())
        response_body = json.loads(brt_response['body'].read())
        print("response_body=", response_body)

        output_value = response_body['generation']

        return jsonify({"output": output_value}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
