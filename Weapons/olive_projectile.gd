extends RigidBody3D

var launch_speed: float = 5.0

func _ready() -> void:
	apply_central_impulse(global_basis * Vector3.FORWARD * launch_speed)
