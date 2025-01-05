
extends Node

# Amazon Bedrock credentials and configuration
const AWS_REGION = "us-east-1" 
const MODEL_ID = "anthropic.claude-v2"

var bedrock_client
var http_request

func _ready():
    # Initialize HTTP request node
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.connect("request_completed", self, "_on_request_completed")
    
    # Initialize AWS credentials
    # Note: Use environment variables or secure storage in production
    var credentials = {
        "aws_access_key_id": "YOUR_ACCESS_KEY",
        "aws_secret_access_key": "YOUR_SECRET_KEY"
    }
    
    # Setup Bedrock client
    setup_bedrock_client(credentials)

func setup_bedrock_client(credentials):
    # Create headers with AWS authentication
    var headers = [
        "Content-Type: application/json",
        "X-Amz-Target: com.amazonaws.bedrock.runtime.BedrockRuntime.InvokeModel"
    ]
    
    bedrock_client = {
        "headers": headers,
        "endpoint": "https://bedrock-runtime." + AWS_REGION + ".amazonaws.com",
        "credentials": credentials
    }

func invoke_model(prompt: String):
    # Prepare request body for Claude model
    var body = {
        "prompt": "\n\nHuman: " + prompt + "\n\nAssistant:",
        "max_tokens_to_sample": 500,
        "temperature": 0.7,
        "top_p": 1
    }
    
    # Make HTTP POST request to Bedrock
    var url = bedrock_client.endpoint + "/model/" + MODEL_ID + "/invoke"
    var error = http_request.request(url, 
        bedrock_client.headers,
        true,
        HTTPClient.METHOD_POST, 
        JSON.print(body)
    )
    
    if error != OK:
        print("An error occurred in the HTTP request")

func _on_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var response = parse_json(body.get_string_from_utf8())
        print("Model response: ", response.completion)
    else:
        print("Error: ", response_code)

# Example usage
func _input(event):
    if event.is_action_pressed("ui_accept"):
        invoke_model("What is the capital of France?")
