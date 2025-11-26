# ranged_weapon.gd
extends Node3D

@export var fire_rate: float = 2.0
@export var projectile = preload("res://Weapons/olive_projectile.tscn")
@export var projectile_speed: float = 5.0
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type

@export var in_inventory: bool = false

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if Input.is_action_pressed("Fire"):
		if cooldown_timer.is_stopped() and ammo_handler.has_ammo(ammo_type):
			shoot()


func shoot() -> void:
	ammo_handler.use_ammo(ammo_type)
	cooldown_timer.start(1.0 / fire_rate)
	var new_projectile = projectile.instantiate()
	new_projectile.launch_speed = projectile_speed
	new_projectile.position = global_position
	new_projectile.rotation = global_rotation
	get_tree().get_root().add_child(new_projectile)
