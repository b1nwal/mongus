extends Node2D

@onready var gemini := GeminiClient.new()

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)

	# Using a template:
	gemini.send_template("weapon", "mountain")
	gemini.send_template("weapon", "mouse")
	gemini.send_template("weapon", "tree")
	gemini.send_template("weapon", "catgirl")
	
	
	

func _on_ai_response(success: bool, data, cached: bool):
	if success:
		print("AI Response (cached=%s): %s" % [cached])
		add_base64_image(data["image"])
		print("fwaa")
	else:
		print("Error:", data)

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
