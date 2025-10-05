extends Label

var seconds_passed: int = 0
var time_accumulator := 0.0

func _ready():
	set_process(true)
	text = format_time(seconds_passed)

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= 1.0:
		seconds_passed += 1
		time_accumulator = 0.0
		text = format_time(seconds_passed)

# Helper function to format time as HH:MM:SS
func format_time(seconds: int) -> String:
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]
