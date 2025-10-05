extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar
@onready var ormm_request = $OrmmRequest


func _ready():
	ormm_request.request("octopus blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("water blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("jogging blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("music blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("heat blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("dog blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("fog blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("green blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("red blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("blood blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("glue blade")
	await get_tree().create_timer(1.0).timeout
	ormm_request.request("gun blade")
	spawn_enemy()
	
func spawn_enemy():
	for i in 10:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)
