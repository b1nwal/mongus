extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Using a template:
	gemini.send_template("weapon", "ice sword", "trash")
	gemini.send_template("weapon", "ice sword", "common")
	gemini.send_template("weapon", "ice sword", "rare")
	gemini.send_template("weapon", "ice sword", "epic")
	gemini.send_template("weapon", "ice sword", "legendary")	
	spawn_enemy()
	
func spawn_enemy():
	for i in 1:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)
