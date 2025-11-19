class_name EnemyPineapple
extends CharacterBody3D


enum EnemyState {
	Wander,
	Alerted,
	Investigate,
	Provoked
}

@export var investigate_duration: float = 2.0
var investigate_timer: float = 0.0

@export var knockback_force: float = 10.0
@export var knockback_duration: float = 0.5
var knockback_timer: float = 0.0
var knockback_direction: Vector3 = Vector3.ZERO

@export var speed: float = 5.0
@export var wander_speed: float = 2.0
@export var aggro_range: float = 12.0
@export var attack_range: float = 1.5
@export var max_hitpoints: int = 100
@export var attack_damage: int = 20

var player: Player
var olive_splat_position: Vector3
var distance_to_player: float
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

var wander_time: float = 0.0
var wander_direction: Vector3

@onready var temp_body: MeshInstance3D = $TempBody
@onready var state_label: Label3D = $StateLabel
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var olive_detector_area_3d: Area3D = $OliveDetectorArea3D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	navigation_agent_3d.navigation_finished.connect(_on_navigation_agent_3d_navigation_finished)
	olive_detector_area_3d.body_entered.connect(_on_olive_detector_body_entered)
	change_state(EnemyState.Wander)


func change_state(new_state: EnemyState) -> void:
	current_state = new_state
	match current_state:
		EnemyState.Wander:
			state_label.text = "Wander"
			randomize_wander_variables()
		EnemyState.Alerted:
			state_label.text = "Alerted"
		EnemyState.Investigate:
			state_label.text = "Investigate"
			investigate_timer = investigate_duration
		EnemyState.Provoked:
			state_label.text = "Provoked"


func _process(delta: float) -> void:
	match current_state:
		EnemyState.Wander:
			if wander_time <= 0.0:
				randomize_wander_variables()
			wander_time -= delta
		EnemyState.Alerted:
			navigation_agent_3d.target_position = olive_splat_position
		EnemyState.Investigate:
			if investigate_timer <= 0.0:
				change_state(EnemyState.Wander)
			investigate_timer -= delta
		EnemyState.Provoked:
			navigation_agent_3d.target_position = player.global_position
			olive_splat_position = Vector3.ZERO # remove last saved instance of an olive if enemy notices player


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= aggro_range:
		change_state(EnemyState.Provoked)
	
	match current_state:
		EnemyState.Wander:
			velocity = wander_direction * wander_speed
			look_at_target(wander_direction)
		
		EnemyState.Alerted:
			var next_position = navigation_agent_3d.get_next_path_position()
			
			var direction = global_position.direction_to(next_position)

			if direction:
				look_at_target(direction)
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed

		EnemyState.Investigate:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
		
		EnemyState.Provoked:
			if distance_to_player <= attack_range:
				attack()
	
			var next_position = navigation_agent_3d.get_next_path_position()
			
			var direction = global_position.direction_to(next_position)

			if direction and knockback_timer <= 0.0:
				look_at_target(direction)
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
	olive_splat_position = olive_instance.global_position
	change_state(EnemyState.Alerted)


func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)


func randomize_wander_variables() -> void:
	wander_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	wander_time = randf_range(1.0, 4.0)


func apply_knockback() -> void:
	knockback_direction = player.global_position.direction_to(global_position).normalized()
	knockback_direction.y = 0
	knockback_timer = knockback_duration


func attack() -> void:
	player.hitpoints -= attack_damage


func _on_navigation_agent_3d_navigation_finished() -> void:
	if current_state == EnemyState.Alerted:
		change_state(EnemyState.Investigate)
