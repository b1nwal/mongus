extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar
@onready var ormm_request = $OrmmRequest

@onready var levelup_popup = $LevelUpPopup

func _ready():
	ormm_request.request("octopus blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("water blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("jogging blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("music blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("heat blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("dog blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("fog blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("green blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("red blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("blood blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("glue blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("gun blade")
	spawn_enemy()
	
	# Connect level up signal
	experience_bar.level_up.connect(_on_level_up)
	
	# Connect popup closed signal
	levelup_popup.popup_closed.connect(_on_levelup_message_submitted)
	
func spawn_enemy():
	for i in 10:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)

func _on_level_up(new_level: int):
	"""Handle level up event - show popup"""
	print("Level up to level ", new_level)
	
	# You can set a custom image here if you want
	# For now, we'll use a default texture or leave it empty
	# levelup_popup.set_image(your_texture_here)
	
	# Show the popup
	levelup_popup.show_popup()

func _on_levelup_message_submitted(message: String):
	"""Handle when user submits their level-up message"""
	print("Player's level-up message: ", message)
	# You can save this message, display it, or do whatever you want with it

func _physics_process(delta):
	
	# Test experience system - press E to add 10 exp, press R to add 50 exp
	if Input.is_action_just_pressed("add_exp_small"):  # E key
		experience_bar.add_experience(10)
		print("Added 10 experience!")
	if Input.is_action_just_pressed("add_exp_large"):  # R key
		experience_bar.add_experience(50)
		print("Added 50 experience!")
