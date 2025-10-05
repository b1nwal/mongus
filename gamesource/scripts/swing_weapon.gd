# sword.gd
extends Weapon
class_name SwingWeapon

var swing_speed: float = 1.0
var slash_angle: float = 135.0
var cooldown: float = 2.0
var internal_cooldown: float = 0.0
var inswing: bool = false
var already_hit: Array = []

func _ready():
	centered = false  # disable automatic centering
	
	# Pull values from the dictionary
	itemname = weapon_info.get("name", "Unnamed Weapon")
	rarity = weapon_info.get("rarity", "Common")
	description = weapon_info.get("description", "No description")
	damage = weapon_info.get("damage", 0)
	
	texture = weapon_info.get("texture", null)
	cooldown = weapon_info.get("cooldown", 2.0)
	internal_cooldown = 0.0
	inswing = false
	already_hit = []
	
	
	modulate.a = 0.0
	
	scale = default_scale
	if weapon_info.get("scale_factor"):
		scale = Vector2(default_scale.x * weapon_info.get("scale_factor"), default_scale.y * weapon_info.get("scale_factor"))
	
	offset = default_offset
	swing_speed = weapon_info.get("swing_speed", swing_speed)
	slash_angle = weapon_info.get("slash_angle", slash_angle)
	
	add_child(create_hitbox_from_image(texture.get_image()))
	

func swing_sword(direction_given: float):
	# Convert angles to radians
	
	if (inswing):
		return
	inswing = true
	
	var start_angle = direction_given - slash_angle/2
	var end_angle = direction_given + slash_angle/2
	rotation_degrees = start_angle
	
	already_hit = []
	var hitbox = null
	
	var tween1 = create_tween()
	modulate.a = 0.0 
	tween1.set_trans(Tween.TRANS_LINEAR)
	tween1.set_ease(Tween.EASE_IN)
	tween1.tween_property(self, "modulate:a", 1.0, (1/swing_speed)/6)
	

	# Always rotate clockwise across the -180/180 boundary safdely
	# Normalize so that tween always moves clockwise
	
	

	for child in get_children():
		if child is Area2D:
			hitbox = child
	  # enable detection
	hitbox.monitoring = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees", start_angle + slash_angle, 0.7).set_delay((1.0 / swing_speed) / 6.0).connect("finished", Callable(hitbox, "set_monitoring"), false)
	
	
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(self, "modulate:a", 0.0,  (1/swing_speed)/6).set_delay(0.7+(1/swing_speed)/6)
	
	inswing = false
	
	
	
	# If there's an existing tween, remove it
	
	
	
func create_hitbox_from_image(image: Image) -> Area2D:
	var width = image.get_width()
	var height = image.get_height()

	var min_x = width
	var min_y = height
	var max_x = 0
	var max_y = 0

	for y in range(height):
		for x in range(width):
			if image.get_pixel(x, y).a > 0.01:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	# Handle fully transparent image
	if max_x < min_x or max_y < min_y:
		push_warning("Image is fully transparent, returning empty Area2D")
		return Area2D.new()

	# Create Area2D and CollisionShape2D
	var area = Area2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2((max_x - min_x + 1)/2.0, (max_y - min_y + 1)/2.0)
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(min_x + shape.extents.x - width/2, min_y + shape.extents.y - height/2 - 200)
	area.add_child(collision)
	area.collision_mask = 2
	area.monitoring = false
	area.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

	
	return area
func _on_hitbox_body_entered(body: Node2D):
	print(damage)
	body.incur(damage)
