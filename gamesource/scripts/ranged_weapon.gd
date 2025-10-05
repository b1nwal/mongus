# sword.gd
extends Weapon
class_name RangedWeapon

var helper := preload("res://scripts/helper.gd")

var draw_speed: float = 1.0
var pierce: int = 1
var cooldown: float = 5.0
var internal_cooldown: float = 0.0
var range: float = 3.0
var speed: float = 10.0
var projectileTexture: Texture2D = null
var inCast: bool = false
var isBow: bool = false

func _ready():
	centered = false  # disable automatic centering
	
	# Pull values from the dictionary
	itemname = weapon_info.get("name", "Unnamed Weapon")
	rarity = weapon_info.get("rarity", "Common")
	description = weapon_info.get("description", "No description")
	projectileTexture =weapon_info.get("projectileTexture", null)
	damage = weapon_info.get("damage", damage)
	texture = weapon_info.get("texture", null)
	cooldown = weapon_info.get("cooldown", 2.0)
	internal_cooldown = 0.0
	
	if description.to_lower().contains("bow") or itemname.to_lower().contains("bow"):
		isBow = true
	
	modulate.a = 0.0
	scale = default_scale
	if weapon_info.get("scale_factor"):
		scale = Vector2(default_scale.x * weapon_info.get("scale_factor"), default_scale.y * weapon_info.get("scale_factor"))
	offset = default_offset
	if isBow:
		offset = Vector2(-160,-128)
	
	add_child(helper.create_hitbox_from_image(texture.get_image()))

# --- PROJECTILE CLASS ---
# --- PROJECTILE CLASS ---
class Projectile:
	extends Node2D
	var helper := preload("res://scripts/helper.gd")
	
	var speed: float = 10.0
	var range: float = 3.0
	var damage: int = 10
	var pierce: int = 1
	var direction: Vector2 = Vector2.RIGHT
	var distance_traveled: float = 0.0
	var hit_enemies: Array = []
	var sprite: Sprite2D = null
	var hitbox: Area2D = null
	var duration: float = 0.0

	func _init(_texture: Texture2D = null, rot: float = 0.0, _speed: float = 10.0, _range: float = 3.0, _damage: int = 10, _pierce: int = 1):
		speed = _speed
		range = _range
		damage = _damage
		pierce = _pierce
		rotation_degrees = rot
		scale = Vector2(0.25, 0.25)
		
		# Create sprite
		sprite = Sprite2D.new()
		sprite.texture = _texture
		sprite.centered = true
		add_child(sprite)
		
		# Create hitbox
		if _texture:
			hitbox = helper.create_hitbox_from_image(_texture.get_image())
			hitbox.collision_mask = 2
			hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
			add_child(hitbox)

	
	func _process(delta):
		var move_distance = speed * delta * 50
		# Move along the rotation of the projectile
		var move_vector = Vector2.UP.rotated(rotation) * move_distance
		position += move_vector
		distance_traveled += move_distance
		duration += delta
		if duration > range:
			queue_free()

	
	func _on_hitbox_body_entered(body: Node2D):
		if body.has_method("incur"):
			body.incur(damage)
			hit_enemies.append(body)
			pierce -= 1
			if pierce <= 0:
				queue_free()

# --- WEAPON FUNCTIONS ---
func throw_projectile(direction_given: float):
	if inCast:
		rotation_degrees = direction_given + 90
		return
		
	inCast = true
	
	# Fade in tween
	var tween1 = create_tween()
	modulate.a = 0.0 
	tween1.set_trans(Tween.TRANS_LINEAR)
	tween1.set_ease(Tween.EASE_IN)
	tween1.tween_property(self, "modulate:a", 1.0, 0.3)
	
	rotation_degrees = direction_given + 90
	
	var start_pos = position
	var direction = Vector2.RIGHT.rotated(rotation) # unit vector in rotation direction
	var target_pos = start_pos + direction * Vector2(7,7)
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, draw_speed/2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	# Move back with overshoot
	var twinge = create_tween()
	twinge.tween_property(self, "position", start_pos, draw_speed/3.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(draw_speed/2)
	
	# Fade out tween
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(1.0)
	tween2.finished.connect(func():
		inCast = false
	)
	
	# Spawn projectile at the same time
	pew(direction_given)

func pew(direction):
	if not projectileTexture:
		print("No projectile texture assigned")
		return
	
	var proj = Projectile.new(
		projectileTexture,
		direction,
		speed,
		range,
		damage,
		pierce
	)
	proj.position = global_position
	get_tree().current_scene.add_child(proj)


func _on_hitbox_body_entered(body: Node2D):
	if body.has_method("incur"):
		body.incur(damage)
