extends Node

# Global data manager to store player data between scenes
var total_experience_gained: int = 0
var player_name: String = ""

func set_total_experience(exp: int):
	"""Set the total experience gained"""
	total_experience_gained = exp
	print("Total experience saved: ", exp)

func get_total_experience() -> int:
	"""Get the total experience gained"""
	return total_experience_gained

func set_player_name(name: String):
	"""Set the player name"""
	player_name = name

func get_player_name() -> String:
	"""Get the player name"""
	return player_name

func reset_data():
	"""Reset all data"""
	total_experience_gained = 0
	player_name = ""
