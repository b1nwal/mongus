extends Node

@onready var gemini := GeminiClient.new()

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Use a prebuilt template
	gemini.send_template("weapon", "ice sword")

func _on_ai_response(success: bool, data):
	if success:
		print("AI Response:", data)
	else:
		print("Error:", data)
