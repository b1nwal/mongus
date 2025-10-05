extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

# Health system variables
var current_health: int = 100
var max_health: int = 100

# Configurable values that can be easily adjusted
@export var default_max_health: int = 100

func _ready():
	max_health = default_max_health
	current_health = max_health
	update_ui()

#func take_damage(amount: int):
	#"""Reduce health by the specified amount"""
	#if current_health > 0:
		#current_health = max(0, current_health - amount)
		#update_ui()
		#
		## Check if health reaches 0
		#if current_health <= 0:
			#on_health_zero()
#
#func heal(amount: int):
	#"""Restore health by the specified amount"""
	#current_health = min(max_health, current_health + amount)
	#update_ui()

func set_health(health: int):
	"""Set the current health to a specific value"""
	current_health = clamp(health, 0, max_health)
	update_ui()

#func set_max_health(new_max: int):
	#"""Set the maximum health"""
	#max_health = new_max
	#current_health = min(current_health, max_health)
	#update_ui()

func update_ui():
	"""Update the health bar and label display"""
	# Update progress bar (0-100 scale)
	var health_percentage = (float(current_health) / float(max_health)) * 100.0
	health_bar.value = health_percentage
	
	# Update health label
	health_label.text = str(current_health) + "/" + str(max_health)

#func on_health_zero():
	#"""Called when health reaches 0 - override this for custom behavior"""
	#print("Health reached 0! Player is defeated.")
	## You can add custom logic here for what happens when health reaches 0
#
#func get_current_health() -> int:
	#"""Get the current health"""
	#return current_health
#
#func get_max_health() -> int:
	#"""Get the maximum health"""
	#return max_health
#
#func get_health_percentage() -> float:
	#"""Get health as a percentage (0.0 to 1.0)"""
	#return float(current_health) / float(max_health)
#
#func is_alive() -> bool:
	#"""Check if the player is still alive"""
	#return current_health > 0
