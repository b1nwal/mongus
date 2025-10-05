extends "res://scripts/entity.gd"

@export var swing_test_key: Key = Key.KEY_Q
var between: float = 0.0
func _process(delta):
	# Check if the swing test key was just pressed
	
	
	if Input.is_key_pressed(swing_test_key):
		between += delta
		if (between >= 3.5):
			_swing_all_weapons()
			between = 0.0

# Function to swing all weapon children
func _swing_all_weapons():
	# Loop over all direct children
	for child in get_children():
		# Only swing weapons (Sword, or any Weapon subclass)
		if child is Weapon:
			# Only swing if it has a swing_sword method (optional safety check)
			if child.has_method("swing_sword"):
				var random_angle = randi() % 360  # Random angle between 0 and 359 degrees
				child.swing_sword(random_angle)
				
				
