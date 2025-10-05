extends Node

class_name Damage


var source: String = ""
var damage: int = 0


func apply(target):
	target.incur(damage)
