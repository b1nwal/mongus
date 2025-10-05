extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var worldnode = $WorldNode
@onready var experience_bar = $ExperienceBar
@onready var health_bar = $HealthBar

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Use a prebuilt template
	gemini.send_template("weapon", "ice sword")
	spawn_enemy()
	
func spawn_enemy():
	for i in 1:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)

func _on_ai_response(success: bool, data, cached: bool):
	if success:
		print("AI Response (cached=%s): %s" % [cached])
		add_base64_image(data["image"])
		print("fwaa")
	else:
		print("Error:", data)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])

var image_count := 0
const IMAGE_SIZE := Vector2(256, 256)

func add_base64_image(base64_string: String) -> void:
	# Decode Base64 into raw bytes
	var raw_image_data = Marshalls.base64_to_raw(base64_string)
	
	# Load bytes into an Image
	var img = Image.new()
	var err = img.load_png_from_buffer(raw_image_data)
	if err != OK:
		push_error("Failed to load image from Base64")
		return
	
	# Create a Texture2D from the Image
	var image_texture = ImageTexture.create_from_image(img)
	
	# Create a Sprite2D and assign the texture
	var sprite = Sprite2D.new()
	sprite.texture = image_texture
	
	# Position it based on the number of images added (tiling horizontally)
	
	sprite.position = Vector2(IMAGE_SIZE.x * image_count+100, 150)

	# Add the sprite as a child
	add_child(sprite)
	
	# Increment image counter
	image_count += 1

func _physics_process(delta):
	
	# Test experience system - press E to add 10 exp, press R to add 50 exp
	if Input.is_action_just_pressed("add_exp_small"):  # E key
		experience_bar.add_experience(10)
		print("Added 10 experience!")
	if Input.is_action_just_pressed("add_exp_large"):  # R key
		experience_bar.add_experience(50)
		print("Added 50 experience!")
	
	# Test health system - press T for small damage, Y for large damage, U to heal
	if Input.is_action_just_pressed("damage_small"):  # T key
		health_bar.take_damage(10)
		print("Took 10 damage! Health: ", health_bar.get_current_health())
	if Input.is_action_just_pressed("damage_large"):  # Y key
		health_bar.take_damage(25)
		print("Took 25 damage! Health: ", health_bar.get_current_health())
	if Input.is_action_just_pressed("heal_player"):  # U key
		health_bar.heal(20)
		print("Healed 20 health! Health: ", health_bar.get_current_health())
		
