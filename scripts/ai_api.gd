extends Node


const RESPONSE_ENDPOINT = "http://127.0.0.1:5000/ai-response"


func make_ai_response(prompt: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(RESPONSE_ENDPOINT, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"prompt": prompt}))
	var resp = await http_request.request_completed
	var body_str = resp[3].get_string_from_utf8()
	
	http_request.queue_free()
	
	var json = JSON.new()
	json.parse(body_str)
	var response = json.get_data()
	return response["output"]
