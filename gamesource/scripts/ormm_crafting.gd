extends Node

@onready var gemini := GeminiClient.new()
@onready var SBPlayer = get_node("/root/Main/SBPlayer")

func _ready():
	add_child(gemini)
	gemini.request_completed.connect(_on_ai_response)
	get_node("/root/Main/SBPlayer/CraftingPopup").submit_craft.connect(craft_request)

func _on_ai_response(success: bool, data, cached: bool):
	if success:
		SBPlayer.add_weapon(data)
	else:
		print("Error:", data)

func craft_request(w1: Weapon, w2: Weapon):
	var prompt1 = gemini.PROMPT_TEMPLATES["weapon"].call("moon", "common")
	var s1 = "weapon:" + prompt1
	var prompt2 = gemini.PROMPT_TEMPLATES["weapon"].call("moon", "common")
	var s2 = "weapon:" + prompt2
	gemini.send_typed_prompt("merge", JSON.stringify({"id1": s1.md5_text(), "id2": s2.md5_text()}))
