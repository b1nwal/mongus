extends Node

func _ready():
	print("test")
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://dog.ceo/api/breeds/image/random")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])
