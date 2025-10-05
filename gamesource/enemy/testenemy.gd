extends "res://scripts/character.gd"

var damage = 20
var target

func _process(delta):
	print(position)

func attack_player():
	target.incur(damage)
