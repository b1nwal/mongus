extends Node2D

@onready var experience_label: Label = $UI/MainContainer/ExperienceLabel
@onready var name_input: LineEdit = $UI/MainContainer/NameInputContainer/NameInput
@onready var submit_button: Button = $UI/MainContainer/SubmitButton
@onready var leaderboard_list: VBoxContainer = $UI/MainContainer/LeaderboardContainer/LeaderboardList
@onready var restart_button: Button = $UI/MainContainer/RestartButton

var player_experience: int = 0
var player_name: String = ""

func _ready():
	get_tree().paused = false
	print("Play Again Screen loaded!")
	
	# Connect signals
	submit_button.pressed.connect(_on_submit_pressed)
	name_input.text_submitted.connect(_on_name_submitted)
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Load player experience from global data
	load_player_experience()
	
	# Load and display leaderboard
	load_leaderboard()

func load_player_experience():
	"""Load the total experience gained from global data"""
	var global_data = get_node("/root/GlobalData")
	if global_data:
		player_experience = global_data.get_total_experience()
		experience_label.text = "Experience Gained: " + str(player_experience)
		print("Loaded player experience: ", player_experience)
	else:
		print("Global data not found!")
		experience_label.text = "Experience Gained: 0"

func _on_submit_pressed():
	"""Handle submit button press"""
	submit_score()

func _on_name_submitted(text: String):
	"""Handle name input submission (Enter key)"""
	submit_score()

func submit_score():
	"""Submit the player's score to Firebase"""
	player_name = name_input.text.strip_edges()
	
	if player_name == "":
		print("Please enter a name!")
		return
	
	print("Submitting score: ", player_name, " - ", player_experience)
	
	# Cache the score to Firebase
	cache_score_to_firebase(player_name, player_experience)
	
	# Show restart button after submission
	restart_button.visible = true
	
	# Reload leaderboard to show updated scores
	load_leaderboard()

func cache_score_to_firebase(name: String, experience: int):
	"""Cache the player's score to Firebase server"""
	# This is a placeholder for Firebase integration
	# You would implement actual Firebase calls here
	print("Caching to Firebase: ", name, " - ", experience)
	
	# For now, we'll simulate Firebase caching
	# In a real implementation, you would use Firebase REST API or Firebase SDK
	# Example Firebase REST API call:
	# var url = "https://your-project.firebaseio.com/scores.json"
	# var data = {"name": name, "experience": experience, "timestamp": Time.get_unix_time_from_system()}
	# HTTPRequest.post(url, data)

func load_leaderboard():
	"""Load and display the high scores leaderboard from Firebase"""
	# Clear existing leaderboard items
	for child in leaderboard_list.get_children():
		child.queue_free()
	
	# This is a placeholder for Firebase integration
	# You would fetch actual scores from Firebase here
	# For now, we'll show some sample scores
	var sample_scores = [
		{"name": "Player1", "experience": 50},
		{"name": "Player2", "experience": 45},
		{"name": "Player3", "experience": 40},
		{"name": "Player4", "experience": 35},
		{"name": "Player5", "experience": 30}
	]
	
	# Sort scores from highest to lowest
	sample_scores.sort_custom(func(a, b): return a.experience > b.experience)
	
	# Display top 10 scores
	for i in range(min(10, sample_scores.size())):
		var score_data = sample_scores[i]
		var score_label = Label.new()
		score_label.text = str(i + 1) + ". " + score_data.name + " - " + str(score_data.experience) + " XP"
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		leaderboard_list.add_child(score_label)

func _on_restart_pressed():
	"""Handle restart button press - go back to main scene"""
	print("Restarting game...")
	
	# Reset global data
	var global_data = get_node("/root/GlobalData")
	if global_data:
		global_data.reset_data()
	
	# Change to main scene
	get_tree().change_scene_to_file("res://main.tscn")
