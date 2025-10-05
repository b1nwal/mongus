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
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])

var player_speed = 400;

@onready var worldnode = $WorldNode

func _physics_process(delta):
	var movement = Vector2.ZERO
	var pleft = Input.is_action_pressed("ui_left")
	var pright = Input.is_action_pressed("ui_right")
	var pup = Input.is_action_pressed("ui_up")
	var pdown = Input.is_action_pressed("ui_down")
	
	if pright and pup:
		movement.x -= player_speed / 1.4 * delta
		movement.y += player_speed / 1.4 * delta
	elif pright and pdown:
		movement.x -= player_speed / 1.4 * delta
		movement.y -= player_speed / 1.4 * delta
	elif pleft and pup:
		movement.x += player_speed / 1.4 * delta
		movement.y += player_speed / 1.4 * delta
	elif pleft and pdown:
		movement.x += player_speed / 1.4 * delta
		movement.y -= player_speed / 1.4 * delta
	elif pleft:
		movement.x += player_speed * delta
	elif pright:
		movement.x -= player_speed * delta
	elif pup:
		movement.y += player_speed * delta
	elif pdown:
		movement.y -= player_speed * delta
	worldnode.position += movement
