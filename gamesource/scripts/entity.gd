extends CharacterBody2D
class_name Entity

var health = 100
var alive = true
var speed = 100

var damage_popup_scene := preload("res://DamagePopup.tscn")

func incur(dmg: int):
	var was_alive = health > 0
	health -= dmg
	var is_dead = health <= 0

	# Spawn the popup before deletion
	var popup = damage_popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)

	# Use global position since popup is added to the scene root
	popup.global_position = global_position + Vector2(0, -16)
	popup.show_damage(dmg, is_dead)

	if is_dead and was_alive:
		die()




func die():
	print("i'm dead")
	alive = false
	queue_free()
