# inventory_ui.gd
extends Control

@onready var item_list = $InventoryList
@onready var inventory = get_parent().inventory

func update_ui():
	item_list.clear()
	for item in inventory.items:
		item_list.add_item("", item.weapon_info.texture)
