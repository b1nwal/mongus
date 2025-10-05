extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar
@onready var ormm_request = $OrmmRequest


func _ready():
	ormm_request.request("octopus blade")
	ormm_request.request("water blade")
	ormm_request.request("jogging blade")
	ormm_request.request("music blade")
	ormm_request.request("heat blade")
	ormm_request.request("dog blade")
	ormm_request.request("fog blade")
	ormm_request.request("green blade")
	ormm_request.request("red blade")
	ormm_request.request("blood blade")
	ormm_request.request("glue blade")
	ormm_request.request("gun blade")
	spawn_enemy()
	
func spawn_enemy():
	for i in 10:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)
