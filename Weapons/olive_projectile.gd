class_name OliveProjectile
extends RigidBody3D

signal splatted(olive_instance)

var launch_speed: float = 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	apply_central_impulse(global_basis * Vector3.FORWARD * launch_speed)


func _on_body_entered(_body: Node) -> void:
	splatted.emit(self)
	queue_free()
