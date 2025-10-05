extends Control

@onready var image_display: TextureRect = $PopupContainer/MainBox/ImageContainer/ImageDisplay
@onready var play_again_button: Button = $PlayAgainButton

signal play_again_pressed

var is_active: bool = false

func _ready():
	# Connect signals
	play_again_button.pressed.connect(_on_play_again_pressed)
	
	# Set process mode for input elements to always process
	play_again_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initially hide the popup
	visible = false

func show_death_screen():
	"""Show the death screen and pause the game"""
	is_active = true
	visible = true
	
	# Pause the game but keep this popup unpaused
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set process mode for all interactive elements
	play_again_button.process_mode = Node.PROCESS_MODE_ALWAYS

func hide_death_screen():
	"""Hide the death screen and resume the game"""
	is_active = false
	visible = false
	
	# Reset process mode to normal
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Resume the game
	get_tree().paused = false

func set_image(texture: Texture2D):
	"""Set the image to display in the death screen"""
	image_display.texture = texture

func _on_play_again_pressed():
	"""Handle play again button press"""
	print("Play again button pressed!")
	play_again_pressed.emit()
	
	# Change to play again scene
	get_tree().change_scene_to_file("res://play_again_screen.tscn")

func _input(event):
	"""Handle input events"""
	if is_active and event.is_action_pressed("ui_accept"):
		# Allow enter key to trigger play again
		_on_play_again_pressed()
