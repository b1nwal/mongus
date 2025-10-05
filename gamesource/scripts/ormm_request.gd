extends Node

@onready var gemini := GeminiClient.new()

func request(r: String):
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)
	gemini.send_template("weapon", r, "common")
	
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
	swing_weapon.weapon_info = {"name": data["name"], "damage": data["damage"], "texture": image_texture, "slash_angle": data["slashAngle"], "swing_speed": data["swingSpeed"],"scale_factor": data["scaleFactor"]}

	# Add the sprite as a child
	$SBPlayer.add_child(swing_weapon)
	
	# Increment image counter
