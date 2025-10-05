extends Node

@onready var gemini := GeminiClient.new()
@onready var SBPlayer = get_node("/root/Main/SBPlayer")

func request(r: String):
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)
	gemini.send_template("weapon", r, "common")
	
func _on_ai_response(success: bool, data, cached: bool):
	if success:
		SBPlayer.add_weapon(data)
	else:
		print("Error:", data)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])
