extends Control

@onready var image_display: TextureRect = $PopupContainer/MainBox/ImageContainer/ImageDisplay
@onready var text_input: LineEdit = $PopupContainer/MainBox/TextInputContainer/TextInput
@onready var submit_button: Button = $PopupContainer/MainBox/TextInputContainer/SubmitButton

signal popup_closed(message: String)

var is_active: bool = false

func _ready():
	# Connect signals
	submit_button.pressed.connect(_on_submit_pressed)
	text_input.text_submitted.connect(_on_text_submitted)
	
	# Set process mode for input elements to always process
	text_input.process_mode = Node.PROCESS_MODE_ALWAYS
	submit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initially hide the popup
	visible = false

func show_popup():
	"""Show the level-up popup and pause the game"""
	is_active = true
	visible = true
	
	# Pause the game but keep this popup unpaused
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Focus the text input
	text_input.grab_focus()
	text_input.clear()

func hide_popup():
	"""Hide the popup and resume the game"""
	is_active = false
	visible = false
	
	# Reset process mode to normal
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Resume the game
	get_tree().paused = false

func set_image(texture: Texture2D):
	"""Set the image to display in the popup"""
	image_display.texture = texture

func _on_submit_pressed():
	"""Handle submit button press"""
	submit_message()

func _on_text_submitted(text: String):
	"""Handle text input submission (Enter key)"""
	submit_message()

func submit_message():
	"""Submit the message and close the popup"""
	var message = text_input.text.strip_edges()
	
	# Emit signal with the message
	popup_closed.emit(message)
	
	# Hide the popup
	hide_popup()
	
	print("Level-up message: ", message)

func _input(event):
	"""Handle input events"""
	if is_active and event.is_action_pressed("ui_cancel"):
		# Allow escape key to close popup
		submit_message()
