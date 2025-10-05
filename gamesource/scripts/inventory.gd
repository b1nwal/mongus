# inventory.gd
extends Node
class_name Inventory

var items: Array = []

var image_count := 0
const IMAGE_SIZE := Vector2(256, 256)



func add_item(item: Weapon):
	items.append(item)
	print("Added ", item.weapon_info.name)
	if len(items) > 9:
		items.pop_front()

#func remove_item(item: Weapon):
	#if item in items:
		#items.erase(item)
		#print("Removed", item.weapon_info.name)
