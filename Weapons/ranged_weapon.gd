# ranged_weapon.gd
extends Node3D

@export var fire_rate: float = 2.0
#@export var recoil: float = .05
@export var projectile = preload("res://Weapons/olive_projectile.tscn")
@export var projectile_speed: float = 5.0
@export var weapon_damage: int = 15
#@export var muzzle_flash: GPUParticles3D
#@export var sparks: PackedScene
#@export var is_automatic: bool = false
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
#@onready var weapon_start_position: Vector3 = weapon_mesh.position

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_pressed("Fire"):
		if cooldown_timer.is_stopped():
			shoot()
	#if is_automatic:
		#if Input.is_action_pressed("Fire"):
			#if cooldown_timer.is_stopped():
				#shoot()
	#else:
		#if Input.is_action_just_pressed("Fire"):
			#if cooldown_timer.is_stopped():
				#shoot()
	#weapon_mesh.position = weapon_mesh.position.lerp(weapon_start_position, delta * 10.0)


#func _input(event: InputEvent) -> void:
	# Going to need to read attack input here for web build


func shoot() -> void:
	cooldown_timer.start(1.0 / fire_rate)
	var new_projectile = projectile.instantiate()
	new_projectile.launch_speed = projectile_speed
	new_projectile.position = global_position
	new_projectile.rotation = global_rotation
	get_tree().get_root().add_child(new_projectile)
	
	#muzzle_flash.restart()
	#weapon_mesh.position.z -= 1.0
	#var collider = ray_cast_3d.get_collider()
	#printt("Weapon Fired!", collider)
	#if ray_cast_3d.is_colliding():
		#if collider is Enemy:
			#collider.hitpoints -= weapon_damage
			#print("Damaged Enemy!")
		#var spark = sparks.instantiate()
		#add_child(spark)
		#spark.global_position = ray_cast_3d.get_collision_point()
