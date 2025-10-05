extends Node
class_name GeminiClient
## A reusable Gemini API client for your game.
## Supports multiple concurrent requests safely.

# --- CONFIGURATION ---
# The address of your running Node.js Gemini bridge
const SERVER_URL := "http://localhost:3000/generate"

# --- Prompt templates ---
# Templates now only define the "payload" string; "type" is passed separately.
var PROMPT_TEMPLATES := {
	"weapon": func(name: String = "", rarity: String = "any") -> String:
		return "Generate a weapon" + ((" themed around " + name) if name != "" else "") + ". It should have a name, a flavour-text description (purely cosmetic), damage number (integer, positive, scaling based on rarity, between 1 and 1000 NO HIGHER), a swing speed (between 0.3 and 3) which is inversely proportional to the swing angle, a swing angle (between 65 and 275), a scale factor (between 1.0 and 1.5 depending on heft), a cooldown (time between attacks, 0.9-2 seconds), and is " + rarity + " rarity.",
	
	"npc": func(role: String = "") -> String:
		return "Create a JSON list of 3 NPCs for an RPG" + ((" specializing in " + role) if role != "" else "") + ". Include their name, personality, and backstory summary."
}

# --- SIGNALS ---
signal request_started(type: String, payload: String, rarity: String)
signal request_completed(success: bool, data: Variant, cached: bool)

# --- PUBLIC API ---
## Sends a typed prompt to the Gemini bridge
func send_typed_prompt(type_name: String, payload: String):
	emit_signal("request_started", type_name, payload)

	# Create a new HTTPRequest node for each request
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed.bind(http))

	var headers := ["Content-Type: application/json"]
	var body := JSON.stringify({
		"type": type_name,
		"payload": payload
	})

	var err := http.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("GeminiClient request failed: %s" % err)
		http.queue_free()  # cleanup on failure

## Sends a prompt using a predefined template
func send_template(template_name: String, arg: String = "", rarity: String = "any"):
	if not PROMPT_TEMPLATES.has(template_name):
		push_error("Unknown prompt template: %s" % template_name)
		return
	
	var payload: String = PROMPT_TEMPLATES[template_name].call(arg, rarity)

	
	send_typed_prompt(template_name, payload)

# --- CALLBACK ---
func _on_request_completed(result, response_code, headers, body, http: HTTPRequest):
	var text: String = body.get_string_from_utf8()
	var response_data: Variant = {}
	var success := false
	var cached := false

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

	# Cleanup this temporary HTTPRequest node
	http.queue_free()
