extends Control

func update(w: Weapon):
	$ItemName.add_text(w.weapon_info.name)
	$Description.add_text(w.weapon_info.description)
	$Panel2/TextureRect.texture = w.weapon_info.texture
	visible = true
	await get_tree().create_timer(4.0).timeout
	visible = false
