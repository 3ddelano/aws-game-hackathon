# AI-Powered Response Generation API

This project is a Flask-based web application that serves as an API endpoint for generating AI-powered responses using AWS Bedrock's Mistral language model.

The application provides a simple interface for developers to integrate AI-generated responses into their applications. It leverages the capabilities of the Mistral language model hosted on AWS Bedrock to generate contextually relevant and coherent responses based on user-provided prompts.

Key features of this API include:
- Single endpoint for generating AI responses
- Integration with AWS Bedrock service
- Configurable response parameters (temperature, top_p)
- Error handling and appropriate status codes
- Optional mock response mode for testing

## Repository Structure

```
.
├── server.py
├── components/
├── entities/
├── scenes/
├── scripts/
└── ui/
```

### Key Files:
- `server.py`: The main entry point and core logic of the API
- `.env`: (Not visible in the tree, but required) Contains AWS credentials and configuration

## Usage Instructions

### Installation

Prerequisites:
- Python 3.7+
- pip
- AWS account with Bedrock access

Steps:
1. Clone the repository
2. Install dependencies:
   ```bash
   pip install flask python-dotenv boto3
   ```
3. Set up environment variables in a `.env` file:
   ```
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

### Getting Started

1. Start the Flask server:
   ```bash
   python server.py
   ```
2. The API will be available at `http://localhost:5000`

### API Usage

To generate an AI response, send a POST request to the `/ai-response` endpoint:

```python
import requests
import json

url = "http://localhost:5000/ai-response"
headers = {"Content-Type": "application/json"}
data = {"prompt": "Tell me about innovative farming methods"}

response = requests.post(url, headers=headers, data=json.dumps(data))
print(response.json())
```

### Configuration Options

- `MOCK_RESPONSE`: Set to `True` in `server.py` to return a mock response instead of calling AWS Bedrock
- `MODEL_ID`: Change the Mistral model version in `server.py` if needed
- Adjust `temperature` and `top_p` values in the `native_request` dictionary to control response randomness

### Troubleshooting

Common issues and solutions:

1. AWS Credentials Not Found
   - Error: `botocore.exceptions.NoCredentialsError`
   - Solution: Ensure AWS credentials are correctly set in the `.env` file
   - Diagnostic: Print `os.getenv('AWS_ACCESS_KEY_ID')` to verify

2. Model Invocation Fails
   - Error: `botocore.exceptions.ClientError`
   - Solution: Check AWS Bedrock service status and your account permissions
   - Debug: Enable verbose logging in boto3:
     ```python
     import boto3
     boto3.set_stream_logger('')
     ```

3. Rate Limiting
   - Error: HTTP 429 Too Many Requests
   - Solution: Implement exponential backoff or reduce request frequency
   - Monitoring: Track `X-RateLimit-Remaining` header in AWS Bedrock responses

### Performance Optimization

- Monitor response times using the built-in timing:
  ```python
  print(f"Took={time.time() - start_time}")
  ```
- Implement caching for frequent prompts to reduce API calls
- Consider batching requests if processing multiple prompts

## Data Flow

The request data flow through the application follows these steps:

1. Client sends a POST request to `/ai-response` with a JSON payload containing the prompt
2. Flask route handler extracts the prompt from the request body
3. The application constructs a request payload for AWS Bedrock
4. If not in mock mode, the application calls AWS Bedrock service
5. AWS Bedrock generates a response using the Mistral model
6. The application processes the response and returns it to the client

```
Client -> Flask App -> AWS Bedrock -> Mistral Model
           ^                                  |
           |                                  |
           +----------------------------------+
```

Note: Ensure proper error handling and retries for network issues or service unavailability.

## Deployment

### Prerequisites
- AWS account with Bedrock access
- Python environment (3.7+)
- Web server (e.g., Gunicorn) for production deployment

### Deployment Steps
1. Set up a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```
2. Install production dependencies:
   ```bash
   pip install flask python-dotenv boto3 gunicorn
   ```
3. Set environment variables securely (do not use .env in production)
4. Run the application using a production WSGI server:
   ```bash
   gunicorn -w 4 -b 0.0.0.0:8000 server:app
   ```

### Environment Configurations
- Ensure `DEBUG=False` for production
- Use environment-specific configuration files or environment variables
- Implement proper logging for production environments

### Monitoring Setup
- Integrate with AWS CloudWatch for logs and metrics
- Set up alerts for error rates and response times
- Monitor AWS Bedrock usage and costs