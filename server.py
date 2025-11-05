import os
from dotenv import load_dotenv
import google.generativeai as genai
import json
from flask import Flask, request, jsonify
import time

load_dotenv()

MOCK_RESPONSE = False

GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
MODEL_ID = "gemini-1.5-flash"

# Configure Gemini API
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

app = Flask(__name__)

@app.route('/ai-response', methods=['POST'])
def post_ai_response():
    try:
        data = request.get_json()

        if not data or 'prompt' not in data:
            return jsonify({"error": "Missing 'prompt' in request body"}), 400

        input_value = data['prompt']
        prompt = input_value + ". Strictly respond in plain text, limited to 4 sentences."

        if MOCK_RESPONSE:
            time.sleep(3)
            return jsonify({"output": "Mocked response. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris lorem ligula, convallis a massa nec, lacinia commodo lectus. Praesent quis felis viverra, faucibus nisi nec, ullamcorper magna. Phasellus ut augue ac tortor elementum euismod nec sed felis. Fusce ut arcu pretium massa gravida sodales non at diam. Donec non risus ipsum."}), 200

        if not GEMINI_API_KEY:
            return jsonify({"error": "GEMINI_API_KEY not configured"}), 500

        print(f"Calling Google Gemini API: model={MODEL_ID}")
        start_time = time.time()

        # Create the model
        model = genai.GenerativeModel(MODEL_ID)

        # Configure generation parameters
        generation_config = {
            "temperature": 0.6,
            "top_p": 0.9,
            "max_output_tokens": 200,
        }

        # Generate response
        response = model.generate_content(
            prompt,
            generation_config=generation_config
        )

        print(f"Took={time.time() - start_time:.2f}s")

        if response.text:
            return jsonify({"output": response.text}), 200
        else:
            return jsonify({"error": "No response from Gemini API"}), 500

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
