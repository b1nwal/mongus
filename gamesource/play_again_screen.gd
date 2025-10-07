extends Node2D

@onready var experience_label: Label = $UI/MainContainer/ExperienceLabel
@onready var name_input: LineEdit = $UI/MainContainer/NameInputContainer/NameInput
@onready var submit_button: Button = $UI/MainContainer/SubmitButton
@onready var leaderboard_list: VBoxContainer = $UI/MainContainer/LeaderboardContainer/LeaderboardList
@onready var restart_button: Button = $UI/MainContainer/RestartButton

var player_experience: int = 0
var player_name: String = ""
var score_submitted: bool = false

func _ready():
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
	player_experience = GlobalData.get_total_experience()
	experience_label.text = "Experience Gained: " + str(player_experience)
	print("Loaded player experience: ", player_experience)

func _on_submit_pressed():
	"""Handle submit button press"""
	submit_score()

func _on_name_submitted(text: String):
	"""Handle name input submission (Enter key)"""
	submit_score()

func submit_score():
	"""Submit the player's score to Firestore"""
	# Check if score has already been submitted
	if score_submitted:
		print("Score already submitted!")
		return
	
	player_name = name_input.text.strip_edges()
	
	if player_name == "":
		print("Please enter a name!")
		return
	
	# Mark score as submitted
	score_submitted = true
	
	# Disable submit button and name input
	submit_button.disabled = true
	submit_button.text = "Score Submitted!"
	name_input.editable = false
	name_input.placeholder_text = "Score submitted!"
	
	print("Submitting score: ", player_name, " - ", player_experience)
	
	# Cache the score to Firestore
	cache_score_to_firestore(player_name, player_experience)
	
	# Show restart button after submission
	restart_button.visible = true
	
	# Reload leaderboard to show updated scores
	load_leaderboard()

func cache_score_to_firestore(name: String, experience: int):
	"""Cache the player's score to Firestore database"""
	# Make HTTP request to the server to save the score
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var url = "http://localhost:3000/api/save-score"
	var data = {
		"name": name,
		"experience": experience,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var json_string = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	http_request.request_completed.connect(_on_score_saved)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)

func _on_score_saved(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle response from score saving"""
	if response_code == 200:
		print("Score saved successfully!")
	else:
		print("Failed to save score. Response code: ", response_code)

func load_leaderboard():
	"""Load and display the high scores leaderboard from Firestore"""
	# Clear existing leaderboard items
	for child in leaderboard_list.get_children():
		child.queue_free()
	
	# Make HTTP request to get leaderboard
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var url = "http://localhost:3000/api/leaderboard"
	
	http_request.request_completed.connect(_on_leaderboard_loaded)
	http_request.request(url, [], HTTPClient.METHOD_GET)

func _on_leaderboard_loaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle response from leaderboard loading"""
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var scores = json.data
			display_leaderboard(scores)
		else:
			print("Failed to parse leaderboard data")
			# Show sample data as fallback
			show_sample_leaderboard()
	else:
		print("Failed to load leaderboard. Response code: ", response_code)
		# Show sample data as fallback
		show_sample_leaderboard()

func display_leaderboard(scores: Array):
	"""Display the leaderboard scores"""
	# Sort scores from highest to lowest
	scores.sort_custom(func(a, b): return a.experience > b.experience)
	
	# Display top 10 scores
	for i in range(min(10, scores.size())):
		var score_data = scores[i]
		var score_label = Label.new()
		score_label.text = str(i + 1) + ". " + score_data.name + " - " + str(score_data.experience) + " XP"
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		leaderboard_list.add_child(score_label)

func show_sample_leaderboard():
	"""Show sample leaderboard data as fallback"""
	var sample_scores = [
		{"name": "Player1", "experience": 50},
		{"name": "Player2", "experience": 45},
		{"name": "Player3", "experience": 40},
		{"name": "Player4", "experience": 35},
		{"name": "Player5", "experience": 30}
	]
	display_leaderboard(sample_scores)

func _on_restart_pressed():
	"""Handle restart button press - go back to main scene"""
	print("Restarting game...")
	
	# Reset global data
	GlobalData.reset_data()
	
	# Change to main scene
	get_tree().change_scene_to_file("res://main.tscn")
