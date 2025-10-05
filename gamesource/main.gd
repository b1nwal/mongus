extends Node

func _ready():
	print("test")
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://dog.ceo/api/breeds/image/random")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])

var player_speed = 400;

@onready var worldnode = $WorldNode

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
