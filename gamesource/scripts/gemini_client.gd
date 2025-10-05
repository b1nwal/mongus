extends Node
class_name GeminiClient
## A reusable Gemini API client for your game.
## Requires a local or remote Node.js Gemini bridge.

# --- CONFIGURATION ---
# The address of your running Node.js Gemini bridge
const SERVER_URL := "http://localhost:3000/generate"

# --- Prompt templates ---
# Templates now only define the "payload" string; "type" is passed separately.
var PROMPT_TEMPLATES := {
	"weapon": func(name: String = "") -> String:
		return "Generate a weapon" + ((" themed around " + name) if name != "" else "") + ". It should have a name, a flavour-text description (purely cosmetic), and rarity (single word rarity).",
	
	"npc": func(role: String = "") -> String:
		return "Create a JSON list of 3 NPCs for an RPG" + ((" specializing in " + role) if role != "" else "") + ". Include their name, personality, and backstory summary."
}

# --- SIGNALS ---
signal request_started(type: String, payload: String)
signal request_completed(success: bool, data: Variant, cached: bool)

# --- INTERNALS ---
@onready var _http := HTTPRequest.new()

func _ready():
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

# --- PUBLIC API ---
## Sends a typed prompt to the Gemini bridge
func send_typed_prompt(type_name: String, payload: String):
	emit_signal("request_started", type_name, payload)
	var headers := ["Content-Type: application/json"]
	var body := JSON.stringify({"type": type_name, "payload": payload})
	var err := _http.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("GeminiClient request failed: %s" % err)

## Sends a prompt using a predefined template
func send_template(template_name: String, arg: String = ""):
	if not PROMPT_TEMPLATES.has(template_name):
		push_error("Unknown prompt template: %s" % template_name)
		return
	var payload = PROMPT_TEMPLATES[template_name].call(arg)
	send_typed_prompt(template_name, payload)

# --- CALLBACK ---
func _on_request_completed(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	var response_data = {}
	var success = false
	var cached = false

	if response_code == 200:
		response_data = JSON.parse_string(text)
		if response_data and response_data.success:
			success = true
			cached = "cached" in response_data and response_data.cached
			response_data = response_data.data
		else:
			response_data = response_data.error
	else:
		response_data = "HTTP error: %d" % response_code

	emit_signal("request_completed", success, response_data, cached)
