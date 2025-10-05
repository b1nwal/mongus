extends CharacterBody2D
class_name Entity

class_name Entity

var health = 100
var alive = true
var speed = 100

func incur(dmg):
	health -= dmg
	if health <= 0:
		die()

func die():
	print("i'm dead")
	alive = false
	queue_free()
