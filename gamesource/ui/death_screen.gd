extends Control

@onready var image_display: TextureRect = $ImageContainer/ImageDisplay
@onready var play_again_button: Button = $PlayAgainButton

func _ready():
	# Initially hide the death screen
	visible = false
	
	# Connect the button
	play_again_button.pressed.connect(_on_play_again_pressed)
	
	image_display.process_mode = Node.PROCESS_MODE_ALWAYS
	play_again_button.process_mode = Node.PROCESS_MODE_ALWAYS

func show_death_screen():
	"""Show the death screen"""
	visible = true
	# Pause the game
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_image(texture: Texture2D):
	"""Set the image to display in the death screen"""
	image_display.texture = texture

func _on_play_again_pressed():
	"""Handle play again button press"""
	print("Play again button pressed!")
	
	# Save total experience to global data before transitioning
	save_player_data()
	
	process_mode = Node.PROCESS_MODE_INHERIT
	# Unpause the game
	get_tree().paused = false
	# Go to play again screen
	get_tree().change_scene_to_file("res://play_again_screen.tscn")

func save_player_data():
	"""Save player data to global data manager"""
	# Try to find the experience bar and save its total experience
	var main_scene = get_node("/root/Main")
	if main_scene:
		var experience_bar = main_scene.get_node("SBPlayer/ExperienceBar")
		if experience_bar:
			var total_exp = experience_bar.get_total_experience_gained()
			GlobalData.set_total_experience(total_exp)
			print("Saved total experience: ", total_exp)
		else:
			print("Experience bar not found!")
	else:
		print("Main scene not found!")


func _on_play_again_button_pressed() -> void:
	pass # Replace with function body.
