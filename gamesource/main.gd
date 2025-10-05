extends Node

var EnemyScene = preload("res://enemy/testenemy.tscn")

@onready var gemini := GeminiClient.new()
@onready var worldnode = $WorldNode

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Use a prebuilt template
	gemini.send_template("weapon", "ice sword")
	spawn_enemy()
	
func spawn_enemy():
	var enemy = EnemyScene.instantiate()
	enemy.position = Vector2(400,400)
	enemy.target = $SBPlayer
	worldnode.add_child(enemy)

func _on_ai_response(success: bool, data):
	if success:
		print("AI Response:", data)
	else:
		print("Error:", data)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])

var player_speed = 400;

func _physics_process(delta):
	var movement = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		movement.x -= player_speed * delta
	if Input.is_action_pressed("ui_left"):
		movement.x += player_speed * delta
	if Input.is_action_pressed("ui_down"):
		movement.y -= player_speed * delta
	if Input.is_action_pressed("ui_up"):
		movement.y += player_speed * delta
	worldnode.position += movement
