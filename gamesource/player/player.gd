extends Entity

@export var swing_test_key: Key = Key.KEY_Q
var between: float = 0.0

@onready var inv_ui = $InventoryUI
var inventory = Inventory.new()

@onready var animated_sprite = $AnimatedSprite

func add_weapon(type: String, data: Dictionary) -> void:
	# Decode Base64 into raw bytes
	
	if type == "weapon":
		var base64_string: String = data["image"]
		var raw_image_data = Marshalls.base64_to_raw(base64_string)
		
		# Load bytes into an Image
		var img = Image.new()
		var err = img.load_png_from_buffer(raw_image_data)
		if err != OK:
			push_error("Failed to load image from Base64")
			return
		
		# Create a Texture2D from the Image
		var image_texture = ImageTexture.create_from_image(img)
		
		var swing_weapon = SwingWeapon.new()
		swing_weapon.weapon_info = {"name": data["name"], "damage": data["damage"], "texture": image_texture, "slash_angle": data["slashAngle"], "swing_speed": data["swingSpeed"],"scale_factor": data["scaleFactor"], "description": data["description"], "cooldown": data["cooldown"]}
		add_child(swing_weapon)
		inventory.add_item(swing_weapon)
		inv_ui.update_ui()
		# Increment image counter
	elif type == "ranged":
		var base64_string: String = data["image"]
		var raw_image_data = Marshalls.base64_to_raw(base64_string)
		
		var base64_string_proj: String = data["projectileImage"]
		var raw_image_data_proj = Marshalls.base64_to_raw(base64_string_proj)
		
		# Load bytes into an Image
		var img = Image.new()
		var err = img.load_png_from_buffer(raw_image_data)
		if err != OK:
			push_error("Failed to load image from Base64")
			return
			
		var img_proj = Image.new()
		var err_proj = img_proj.load_png_from_buffer(raw_image_data_proj)
		if err_proj != OK:
			push_error("Failed to load image from Base64")
			return
		
		# Create a Texture2D from the Image
		var image_texture = ImageTexture.create_from_image(img)
		var image_texture_proj = ImageTexture.create_from_image(img_proj)
		
		var ranged_weapon = RangedWeapon.new()
		ranged_weapon.weapon_info = {
			"name": data["name"], 
			"damage": data["damage"], 
			"texture": image_texture, 
			"projectileTexture": image_texture_proj,
			"draw_speed": data["drawSpeed"], 
			"pierce": data["pierce"],
			"scale_factor": data["scaleFactor"], 
			"description": data["description"], 
			"cooldown": data["cooldown"],
			"range": data["range"],
			"speed": data["speed"]
		}
		
		add_child(ranged_weapon)
		inventory.add_item(ranged_weapon)
		inv_ui.update_ui()
	# Load bytes into an Image
	var img = Image.new()
	var err = img.load_png_from_buffer(raw_image_data)
	if err != OK:
		push_error("Failed to load image from Base64")
		return
	
	# Create a Texture2D from the Image
	var image_texture = ImageTexture.create_from_image(img)
	
	var swing_weapon = SwingWeapon.new()
	swing_weapon.weapon_info = {"name": data["name"], "description": data["description"], "damage": data["damage"], "texture": image_texture, "slash_angle": data["slashAngle"], "swing_speed": data["swingSpeed"],"scale_factor": data["scaleFactor"]}
	$ItemGetPopUp.update(swing_weapon)
	add_child(swing_weapon)
	inventory.add_item(swing_weapon)
	inv_ui.update_ui()
	# Increment image counter

func _process(delta):
	# Check if the swing test key was just pressed
	tick_weapons(delta)
# Function to swing all weapon children
func tick_weapons(delta):
	
	var angle_to_enemy = get_nearest_enemy()
	for child in get_children():
		if child is SwingWeapon:
			child.internal_cooldown += delta
			if child.internal_cooldown > child.cooldown and !child.inswing:
				child.internal_cooldown = 0.0
				if (angle_to_enemy != null):
					child.swing_sword(angle_to_enemy)
		if child is RangedWeapon:
			child.internal_cooldown += delta
			if child.internal_cooldown > child.cooldown:
				if (angle_to_enemy != null):
					child.throw_projectile(angle_to_enemy)
				
var player_speed = 300;

func get_nearest_enemy():
	var used_angle = null
	var current_closest = null
	
	for child in get_tree().root.get_child(0).get_children():
		
		if child is Enemy and (current_closest == null || (self.position - child.position).length() < current_closest.length()):
			used_angle = rad_to_deg(self.position.angle_to_point(child.position))+90
			
			current_closest = self.position - child.position
			
	return used_angle

func die():
	print("PLAYER DEAD")
	# Show death screen instead of just pausing
	show_death_screen()

func show_death_screen():
	"""Show the death screen popup"""
	# Find the death screen in the scene
	var death_screen = get_node("/root/Main/SBPlayer/DeathScreen")
	if death_screen:
		death_screen.show_death_screen()
	else:
		print("Death screen not found!")
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
	
	if (movement.x > 0):
		animated_sprite.play("walk_left")
	if (movement.x < 0):
		animated_sprite.play("walk_right")
	
	if (movement == Vector2(0,0)):
		animated_sprite.play("idle")
	
	move_and_collide(-movement)


func incur(dmg):
	health -= dmg
	if health <= 0:
		die()
	$HealthBar.set_health(health)
