extends Control

@onready var image_display1: TextureRect = $VBoxContainer/ImageContainer1/ImageDisplay1
@onready var image_display2: TextureRect = $ImageContainer2/ImageDisplay2
@onready var image_display3: TextureRect = $ImageContainer3/ImageDisplay3
@onready var submit_button: Button = $VBoxContainer/TextInputContainer/SubmitButton
@onready var crafting_button: Button = get_node("/root/Main/SBPlayer/inGameUI/buttonContainer/craftingButton")
@onready var inventory_list = get_node("/root/Main/SBPlayer/InventoryUI")

signal popup_closed

signal submit_craft(w1: Weapon, w2: Weapon)

var boxes_populated = 0
var box_content = []
var is_active: bool = false
var selected_container: Panel = null
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	# Connect signals
	#submit_button.pressed.connect(_on_submit_pressed)
	inventory_list.click_item.connect(populate_boxes)
	# Set process mode for input elements to always process
	submit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	crafting_button.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_list.process_mode = Node.PROCESS_MODE_ALWAYS
	# Initially hide the popup
	visible = false
func populate_boxes(w: Weapon):
	if boxes_populated < 2:
		boxes_populated += 1
	else:
		return
	if boxes_populated > 0:
		box_content.append(w)
		var c = box_content[boxes_populated-1].weapon_info.texture
		[$ImageContainer2/ImageDisplay2,$ImageContainer3/ImageDisplay3][boxes_populated-1].texture = c

func clear_boxes():
	boxes_populated = 0
	box_content = []
	$ImageContainer2/ImageDisplay2.texture = null
	$ImageContainer3/ImageDisplay3.texture = null

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
	clear_boxes()
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
	if boxes_populated == 2:
		submit_craft.emit(box_content[0], box_content[1])
	
	hide_popup()
