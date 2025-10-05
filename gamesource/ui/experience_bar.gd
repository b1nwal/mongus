extends Control

@onready var exp_bar: ProgressBar = $ExpBar
@onready var level_label: Label = $LevelLabel

# Experience system variables
var current_exp: int = 0
var current_level: int = 1
var exp_to_next_level: int = 100

# Configurable values that can be easily adjusted
@export var base_exp_required: int = 100
@export var exp_scaling_factor: float = 1.5

func _ready():
	update_exp_to_next_level()
	update_ui()

func add_experience(amount: int):
	"""Add experience points to the player"""
	current_exp += amount
	check_level_up()
	update_ui()

func check_level_up():
	"""Check if the player should level up"""
	while current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		current_level += 1
		update_exp_to_next_level()
		print("Level up! Now level ", current_level)

func update_exp_to_next_level():
	"""Calculate the experience required for the next level"""
	exp_to_next_level = int(base_exp_required * pow(exp_scaling_factor, current_level - 1))

func update_ui():
	"""Update the experience bar and level display"""
	# Update progress bar
	var progress = float(current_exp) / float(exp_to_next_level)
	exp_bar.value = progress * 100
	
	# Update level label
	level_label.text = "Level " + str(current_level)

func set_experience(exp: int):
	"""Set the current experience (useful for testing or loading save data)"""
	current_exp = exp
	check_level_up()
	update_ui()

func set_level(level: int):
	"""Set the current level (useful for testing or loading save data)"""
	current_level = level
	update_exp_to_next_level()
	update_ui()

func get_current_exp() -> int:
	"""Get the current experience points"""
	return current_exp

func get_current_level() -> int:
	"""Get the current level"""
	return current_level

func get_exp_to_next_level() -> int:
	"""Get the experience required for the next level"""
	return exp_to_next_level
