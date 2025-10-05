extends Sprite2D
class_name Weapon

# --- CONFIGURATION ---
@export var weapon_info: Dictionary = {
	"name": "Unnamed Weapon",
	"rarity": "Common",
	"description": "No description",
	"damage": 0,
	"texture": null  # Texture2D
}

@export var default_scale: Vector2 = Vector2(0.095, 0.095)
@export var default_offset: Vector2 = Vector2(-128,-320)

# --- INTERNALS ---
var itemname: String = ""
var rarity: String = ""
var description: String = ""
var damage: int = 0
var weapon_texture: ImageTexture = null

func _ready():
	centered = false  # disable automatic centering
	
	# Pull values from the dictionary
	itemname = weapon_info.get("name", "Unnamed Weapon")
	rarity = weapon_info.get("rarity", "Common")
	description = weapon_info.get("description", "No description")
	damage = weapon_info.get("damage", 0)
	
	texture = weapon_info.get("texture", null)
	scale = default_scale
	offset = default_offset
		

func attack():
	print("%s attacks for %d damage!" % [name, damage])

func inspect():
	print("Weapon Info → Name: %s | Rarity: %s | Desc: %s | Damage: %d" %
		[name, rarity, description, damage])
