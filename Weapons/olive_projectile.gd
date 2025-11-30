class_name OliveProjectile
extends RigidBody3D

signal splatted(olive_instance)

@export var splat_particles = preload("res://Weapons/olive_splat_particles.tscn")
@onready var splat_sfx: AudioStreamPlayer3D = $SplatSFX

var launch_speed: float = 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	apply_central_impulse(global_basis * Vector3.FORWARD * launch_speed)


func _on_body_entered(_body: Node) -> void:
	var particles = splat_particles.instantiate()
	get_tree().get_root().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true
	splatted.emit(self)
	
	splat_sfx.play()
	splat_sfx.reparent(get_parent())
	
	queue_free()
