extends Node
class_name GeminiClient
## A reusable Gemini API client for your game.
## Requires a local or remote Node.js Gemini bridge.

# --- CONFIGURATION ---
# The address of your running Node.js Gemini bridge.
const SERVER_URL := "http://localhost:3000/generate"

# Where to define your **prompt templates**.
# Use these to keep prompt styles consistent across the game.
# Example: PROMPT_TEMPLATES.weapon will format the prompt for generating weapons.
var PROMPT_TEMPLATES := {
	"weapon": func(name: String = "") -> String:
		return "Generate a JSON list of 3 fantasy weapons" + ((" themed around " + name) if name != "" else "") + ". Each should have a name, description, and rarity.",
	
	"npc": func(role: String = "") -> String:
		return "Create a JSON list of 3 NPCs for an RPG" + ((" specializing in " + role) if role != "" else "") + ". Include their name, personality, and backstory summary."
}

# --- SIGNALS ---
signal request_started(prompt: String)
signal request_completed(success: bool, data: Variant)

# --- INTERNALS ---
@onready var _http := HTTPRequest.new()

func _ready():
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


# --- PUBLIC API ---
## Sends a prompt string directly to the Gemini bridge.
func send_prompt(prompt: String):
	emit_signal("request_started", prompt)
	var headers := ["Content-Type: application/json"]
	var body := JSON.stringify({"prompt": prompt})
	var err := _http.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("GeminiClient request failed: %s" % err)


## Sends a prompt using one of the predefined templates.
## Example: GeminiClient.send_template("weapon", "fire")
func send_template(template_name: String, arg: String = ""):
	if not PROMPT_TEMPLATES.has(template_name):
		push_error("Unknown prompt template: %s" % template_name)
		return
	var prompt_func = PROMPT_TEMPLATES[template_name]
	send_prompt(prompt_func.call(arg))


# --- CALLBACK ---
func _on_request_completed(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	var response_data = {}
	var success = false

	if response_code == 200:
		response_data = JSON.parse_string(text)
		if response_data and response_data.success:
			success = true
			response_data = response_data.data
		else:
			response_data = response_data.error
	else:
		response_data = "HTTP error: %d" % response_code

	emit_signal("request_completed", success, response_data)
