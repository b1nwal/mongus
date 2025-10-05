extends CharacterBody2D

var health = 100
var alive = true

func incur(dmg):
	health -= dmg
	if health <= 0:
		die()

func die():
	print("i'm dead")
	alive = false
	queue_free()
