class_name Interactable
extends CollisionObject3D


signal interacted(body)

var is_activated: bool = false

@export var prompt_message: String
@export var prompt_input: String


func get_prompt() -> String:
	if not is_activated:
		var key_name = ""
		for action in InputMap.action_get_events(prompt_input):
			if action is InputEventKey:
				key_name = action.as_text_physical_keycode()
				break
		return prompt_message + "\n[" + key_name + "]"
	else:
		return ""


func interact(body) -> void:
	interacted.emit(body)
