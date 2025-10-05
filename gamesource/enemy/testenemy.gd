extends "res://scripts/entity.gd"

var damage = 20
var target

func _ready():
	speed = 20

func _process(delta):
	print(global_position.distance_to(Vector2(0,0)))
	var direction = (target.position - position).normalized()
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		if collision.get_collider() == target:
			print("hit!")

func attack_player():
	target.incur(damage)
