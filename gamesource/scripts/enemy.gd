extends Entity

class_name Enemy

var damage = 20
var target
var target_in_range

@onready var animated_sprite = $AnimatedSprite

#func _ready():
	#speed = 20

func _process(delta):
	if !target_in_range:
		var direction = (target.position - position).normalized()
		var collision = move_and_collide(direction * speed * delta)
		if (direction.x > 0):
			animated_sprite.play("walk_right")
		if (direction.x < 0):
			animated_sprite.play("walk_left")
	
func die():
	print("i'm dead")
	alive = false
	queue_free()

func attack_player():
	target.incur(damage)

func _enemy_attackbox_entered(body: Node2D) -> void:
	target_in_range = true
	if body.collision_layer & 1:
		if not $AttackBox/AttackTimer.is_stopped():
			return
		$AttackBox/AttackTimer.start()

func _enemy_attackbox_exited(body: Node2D) -> void:
	if body.collision_layer & 1:
		$AttackBox/AttackTimer.stop()
		target_in_range = false

func _on_attack_timer_timeout() -> void:
	if target_in_range:
		print("hit player")
		target.incur(10)
