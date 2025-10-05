extends Node

@onready var gemini := GeminiClient.new()

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Using a template:
	gemini.send_template("weapon", "ice")

func _on_ai_response(success: bool, data, cached: bool):
	if success:
		print("AI Response (cached=%s): %s" % [cached, data])
	else:
		print("Error:", data)
