extends Entity

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
				
				
var player_speed = 300;

func die():
	print("PLAYER DEAD")
	get_tree().paused = true

func _physics_process(delta):
	var movement = Vector2.ZERO
	var pleft = Input.is_action_pressed("ui_left")
	var pright = Input.is_action_pressed("ui_right")
	var pup = Input.is_action_pressed("ui_up")
	var pdown = Input.is_action_pressed("ui_down")
	
	if pright and pup:
		movement.x -= player_speed / 1.4 * delta
		movement.y += player_speed / 1.4 * delta
	elif pright and pdown:
		movement.x -= player_speed / 1.4 * delta
		movement.y -= player_speed / 1.4 * delta
	elif pleft and pup:
		movement.x += player_speed / 1.4 * delta
		movement.y += player_speed / 1.4 * delta
	elif pleft and pdown:
		movement.x += player_speed / 1.4 * delta
		movement.y -= player_speed / 1.4 * delta
	elif pleft:
		movement.x += player_speed * delta
	elif pright:
		movement.x -= player_speed * delta
	elif pup:
		movement.y += player_speed * delta
	elif pdown:
		movement.y -= player_speed * delta
	
	move_and_collide(-movement)


func incur(dmg):
	health -= dmg
	if health <= 0:
		die()
	$HealthBar.set_health(health)
