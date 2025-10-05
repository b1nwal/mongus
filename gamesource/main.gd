extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar
@onready var ormm_request = $OrmmRequest

@onready var levelup_popup = $SBPlayer/LevelUpPopup
@onready var crafting_popup = $SBPlayer/CraftingPopup
@onready var in_game_ui = $SBPlayer/inGameUI

func _ready():
	add_child(gemini)
	
	#ormm_request.request("octopus blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("water blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("jogging blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("music blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("heat blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("dog blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("fog blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("green blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("red blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("blood blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("glue blade")
	#await get_tree().create_timer(1.0).timeout
	#ormm_request.request("gun blade")
	spawn_enemy()
	
	# Connect level up signal
	experience_bar.level_up.connect(_on_level_up)
	
	# Connect crafting button
	connect_crafting_button()
	
func spawn_enemy():
	for i in 1:
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
	
	# Create a Texture2D from the Imagea
	# Show the popup
	levelup_popup.show_popup()

func connect_crafting_button():
	"""Connect the crafting button to toggle the crafting popup"""
	# Find the crafting button in the in_game_ui
	var crafting_button = in_game_ui.get_node("buttonContainer/craftingButton")
	if crafting_button:
		crafting_button.pressed.connect(_on_crafting_button_pressed)
		print("Crafting button connected!")
	else:
		print("Crafting button not found!")

func _on_crafting_button_pressed():
	"""Handle crafting button press - toggle the popup"""
	print("Crafting button pressed!")
	crafting_popup.toggle_popup()

func _physics_process(delta):
	
	# Test experience system - press E to add 10 exp, press R to add 50 exp
	if Input.is_action_just_pressed("add_exp_small"):  # E key
		experience_bar.add_experience(10)
		print("Added 10 experience!")
	if Input.is_action_just_pressed("add_exp_large"):  # R key
		experience_bar.add_experience(50)
		print("Added 50 experience!")
