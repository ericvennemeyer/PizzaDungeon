class_name EnemyPineapple
extends CharacterBody3D


enum EnemyState {
	Patrolling,
	Alerted,
	Investigating,
	Provoked
}

@export var investigating_time: float = 2.0

@export var knockback_force: float = 10.0
@export var knockback_duration: float = 0.5
var knockback_timer: float = 0.0
var knockback_direction: Vector3 = Vector3.ZERO

@export var speed: float = 5.0
@export var aggro_range: float = 12.0
@export var attack_range: float = 1.5
@export var max_hitpoints: int = 100
@export var attack_damage: int = 20

var player: Player
var olive_splat_position: Vector3
var provoked: bool = false # provoked is for Player
var alerted: bool = false # alerted is for Olives
var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value
		apply_knockback()
		print(hitpoints)
		if hitpoints <= 0:
			queue_free()
		change_state(EnemyState.Provoked)

var current_state: EnemyState
var state_change_timer: float = 0.0

#var target_angle_y: float
#var rotation_speed: float = 2.0

@onready var temp_body: MeshInstance3D = $TempBody
@onready var state_label: Label3D = $StateLabel
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var olive_detector_area_3d: Area3D = $OliveDetectorArea3D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	olive_detector_area_3d.body_entered.connect(_on_olive_detector_body_entered)
	change_state(EnemyState.Patrolling)


func change_state(new_state: EnemyState) -> void:
	current_state = new_state
	match current_state:
		EnemyState.Patrolling:
			state_label.text = "Patrolling"
		EnemyState.Alerted:
			state_label.text = "Alerted"
		EnemyState.Investigating:
			state_label.text = "Investigating"
		EnemyState.Provoked:
			state_label.text = "Provoked"


func _process(delta: float) -> void:
	match current_state:
		EnemyState.Alerted:
			navigation_agent_3d.target_position = olive_splat_position
		EnemyState.Provoked:
			navigation_agent_3d.target_position = player.global_position
			olive_splat_position = Vector3.ZERO # remove last saved instance of an olive if enemy notices player
	
	## Calculate the current Y-axis rotation
	#var current_angle = transform.basis.get_euler().y
	## Smoothly interpolate towards the target angle
	#var new_angle = lerp_angle(current_angle, target_angle_y, rotation_speed * delta)
	## Apply the new rotation to the object's transform
	#transform.basis = Basis.from_euler(Vector3(transform.basis.get_euler().x, new_angle, transform.basis.get_euler().z))


func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = global_position.direction_to(next_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= aggro_range:
		change_state(EnemyState.Provoked)
	
	if current_state == EnemyState.Provoked and distance_to_player <= attack_range:
		attack()
	
	
	if direction and knockback_timer <= 0.0:
		look_at_target(direction)
		#target_angle_y = direction.y
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if knockback_timer > 0.0:
		velocity += knockback_direction * knockback_force
		knockback_timer -= delta
		

	move_and_slide()


func _on_olive_detector_body_entered(body: Node) -> void:
	if body is OliveProjectile:
		body.splatted.connect(_on_olive_splatted)


func _on_olive_splatted(olive_instance: OliveProjectile) -> void:
	print("I heard an olive at " + str(olive_instance.global_position))
	olive_splat_position = olive_instance.global_position
	change_state(EnemyState.Alerted)


func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)


func apply_knockback() -> void:
	knockback_direction = player.global_position.direction_to(global_position).normalized()
	knockback_direction.y = 0
	knockback_timer = knockback_duration


func attack() -> void:
	player.hitpoints -= attack_damage
