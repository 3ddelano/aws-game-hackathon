import os
from dotenv import load_dotenv
import boto3
import json
from botocore.exceptions import ClientError
from flask import Flask, request, jsonify
import time

load_dotenv()

MOCK_RESPONSE = False

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

        prompt = input_value + "\n Strictly respond in plain text, limited to 4 sentences."



        native_request = {
            "prompt": prompt,
            "max_gen_len": 256,
            "temperature": 1,
            "top_p": 1
        }
        
        if MOCK_RESPONSE:
            time.sleep(3)
            return jsonify({"output": "Mocked resposne. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris lorem ligula, convallis a massa nec, lacinia commodo lectus. Praesent quis felis viverra, faucibus nisi nec, ullamcorper magna. Phasellus ut augue ac tortor elementum euismod nec sed felis. Fusce ut arcu pretium massa gravida sodales non at diam. Donec non risus ipsum."}), 200
        
        print(f"Calling AWS bedrock: model={MODEL_ID}")
        start_time = time.time()
        brt_response = brt.invoke_model(modelId=MODEL_ID, body=json.dumps(native_request).encode())
        response_body = json.loads(brt_response['body'].read())
        print(f"Took={time.time() - start_time}, response_body={response_body}")

        output_value = response_body['generation']

        return jsonify({"output": output_value}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
