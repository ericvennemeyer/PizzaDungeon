extends RigidBody3D


var launch_speed: float = 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	apply_central_impulse(global_basis * Vector3.FORWARD * launch_speed)


func _on_body_entered(body: Node) -> void:
	queue_free()
