# melee_weapon.gd
extends Node3D

@export var fire_rate: float = 2.0
@export var weapon_mesh: Node3D
@export var weapon_damage: int = 15
@export var sparks: PackedScene
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type

@export var in_inventory: bool = false

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(delta: float) -> void:
	if Input.is_action_pressed("Fire"):
		if cooldown_timer.is_stopped():
			shoot()


func shoot() -> void:
	animation_player.play("swing_club")
	cooldown_timer.start(1.0 / fire_rate)


func do_damage() -> void:
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		printt("Weapon Fired!", collider)
		if collider is EnemyPineapple:
			collider.hitpoints -= weapon_damage
			print("Damaged Enemy!")
			var spark = sparks.instantiate()
			add_child(spark)
			spark.global_position = ray_cast_3d.get_collision_point()
