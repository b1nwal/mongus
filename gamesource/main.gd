extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar

func _ready():
	spawn_enemy()
	
func spawn_enemy():
	for i in 1:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)
