extends RayCast3D

var interaction_key: String

@onready var prompt_label: Label = $MarginContainer/PromptLabel


func _physics_process(delta: float) -> void:
	prompt_label.text = ""
	
	if is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			prompt_label.text = collider.get_prompt()
			
			if Input.is_action_just_pressed(collider.prompt_input):
				collider.interact(owner)
