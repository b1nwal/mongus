extends Control

@onready var image_display1: TextureRect = $VBoxContainer/ImageContainer1/ImageDisplay1
@onready var image_display2: TextureRect = $VBoxContainer/ImageContainer2/ImageDisplay2
@onready var image_display3: TextureRect = $VBoxContainer/ImageContainer3/ImageDisplay3
@onready var submit_button: Button = $VBoxContainer/TextInputContainer/SubmitButton
@onready var crafting_button: Button = get_node("/root/Main/SBPlayer/inGameUI/buttonContainer/craftingButton")

signal popup_closed

var is_active: bool = false
var selected_container: Panel = null
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	# Connect signals
	submit_button.pressed.connect(_on_submit_pressed)
	
	# Set process mode for input elements to always process
	submit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	crafting_button.process_mode = Node.PROCESS_MODE_ALWAYS
	# Initially hide the popup
	visible = false

func show_popup():
	"""Show the crafting popup and pause the game"""
	if visible:
		hide_popup()
	is_active = true
	visible = true
	
	# Pause the game but keep this popup unpaused
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	

func hide_popup():
	"""Hide the popup and resume the game"""
	is_active = false
	visible = false
	
	# Reset process mode to normal
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Resume the game
	get_tree().paused = false

func toggle_popup():
	"""Toggle the popup on/off"""
	if is_active:
		hide_popup()
	else:
		show_popup()

func set_image(container_index: int, texture: Texture2D):
	"""Set an image in one of the containers (2, or 3)"""
	match container_index:
		2:
			image_display2.texture = texture
		3:
			image_display3.texture = texture

func _input(event):
	"""Handle input events"""
	if is_active and event.is_action_pressed("ui_cancel"):
		# Allow escape key to close popup
		hide_popup()

func _on_submit_pressed():
	"""Handle submit button press"""
	hide_popup()
