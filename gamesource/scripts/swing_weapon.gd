# sword.gd
extends Weapon
class_name SwingWeapon

var swing_speed: float = 1.0
var slash_angle: float = 135.0
var cooldown: float = 2.0
var internal_cooldown: float = 0.0
var inswing: bool = false

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
	
	modulate.a = 0.0
	
	scale = default_scale
	if weapon_info.get("scale_factor"):
		scale = Vector2(default_scale.x * weapon_info.get("scale_factor"), default_scale.y * weapon_info.get("scale_factor"))
	
	offset = default_offset
	swing_speed = weapon_info.get("swing_speed", swing_speed)
	slash_angle = weapon_info.get("slash_angle", slash_angle)

func swing_sword(direction_given: float):
	# Convert angles to radians
	
	if (inswing):
		return
	inswing = true
	
	var start_angle = direction_given - slash_angle/2
	var end_angle = direction_given + slash_angle/2
	rotation_degrees = start_angle
	
	print(rotation_degrees)
	
	var tween1 = create_tween()
	modulate.a = 0.0 
	tween1.set_trans(Tween.TRANS_LINEAR)
	tween1.set_ease(Tween.EASE_IN)
	tween1.tween_property(self, "modulate:a", 1.0, (1/swing_speed)/6)
	

	# Always rotate clockwise across the -180/180 boundary safely
	# Normalize so that tween always moves clockwise
	
		
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees", start_angle + slash_angle, 0.7/swing_speed).set_delay((1.0 / swing_speed) / 6.0)

	
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(self, "modulate:a", 0.0,  (1/swing_speed)/6).set_delay(0.7/swing_speed+(1/swing_speed)/6)
	
	inswing = false
	
	
	
	# If there's an existing tween, remove it
	
	
