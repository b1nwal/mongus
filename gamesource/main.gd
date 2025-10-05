extends Node2D

var TweakerScene = preload("res://enemy/tweaker.tscn")

@onready var gemini := GeminiClient.new()

@onready var experience_bar = $SBPlayer/ExperienceBar
@onready var health_bar = $SBPlayer/HealthBar

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Using a template:
	gemini.send_template("weapon", "rusty blade", "common")
	
	
	
	

var darp: float = 0.0
func _process(delta):
	darp += delta
	if (darp >= 3.0):
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
		darp = 0.0
	
	
func spawn_enemy():
	for i in 1:
		var tweaker = TweakerScene.instantiate()
		tweaker.position = Vector2(randi_range(-600,600),randi_range(-600,600))
		tweaker.target = $SBPlayer
		add_child(tweaker)

func _on_ai_response(success: bool, data, cached: bool):
	if success:
		add_weapon(data)
	else:
		print("Error:", data)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["message"])

var image_count := 0
const IMAGE_SIZE := Vector2(256, 256)

func add_weapon(data: Dictionary) -> void:
	# Decode Base64 into raw bytes
	var base64_string: String = data["image"]
	var raw_image_data = Marshalls.base64_to_raw(base64_string)
	
	# Load bytes into an Image
	var img = Image.new()
	var err = img.load_png_from_buffer(raw_image_data)
	if err != OK:
		push_error("Failed to load image from Base64")
		return
	
	# Create a Texture2D from the Image
	var image_texture = ImageTexture.create_from_image(img)
	
	var swing_weapon = SwingWeapon.new()
	swing_weapon.weapon_info = {"name": data["name"], "damage": data["damage"], "texture": image_texture, "slash_angle": data["slashAngle"], "swing_speed": data["swingSpeed"],"scale_factor": data["scaleFactor"], "cooldown": data["cooldown"]}

	# Add the sprite as a child
	$SBPlayer.add_child(swing_weapon)
	
	# Increment image counter
