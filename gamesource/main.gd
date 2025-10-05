extends Node

var EnemyScene = preload("res://enemy/testenemy.tscn")

@onready var gemini := GeminiClient.new()
@onready var worldnode = $WorldNode
@onready var experience_bar = $ExperienceBar
@onready var health_bar = $HealthBar

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
	
	# Test experience system - press E to add 10 exp, press R to add 50 exp
	if Input.is_action_just_pressed("add_exp_small"):  # E key
		experience_bar.add_experience(10)
		print("Added 10 experience!")
	if Input.is_action_just_pressed("add_exp_large"):  # R key
		experience_bar.add_experience(50)
		print("Added 50 experience!")
	
	# Test health system - press T for small damage, Y for large damage, U to heal
	if Input.is_action_just_pressed("damage_small"):  # T key
		health_bar.take_damage(10)
		print("Took 10 damage! Health: ", health_bar.get_current_health())
	if Input.is_action_just_pressed("damage_large"):  # Y key
		health_bar.take_damage(25)
		print("Took 25 damage! Health: ", health_bar.get_current_health())
	if Input.is_action_just_pressed("heal_player"):  # U key
		health_bar.heal(20)
		print("Healed 20 health! Health: ", health_bar.get_current_health())
		
