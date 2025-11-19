extends CPUParticles3D


func _ready() -> void:
	finished.connect(_on_particles_finished)


func _on_particles_finished() -> void:
	queue_free()
