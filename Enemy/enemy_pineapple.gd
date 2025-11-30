class_name EnemyPineapple
extends CharacterBody3D


enum EnemyState {
	Wander,
	Alerted,
	Investigate,
	Provoked,
	Stagger
}

@export var investigate_duration: float = 2.0
var investigate_timer: float = 0.0

@export var knockback_force: float = 4.0
@export var knockback_duration: float = 0.2
var knockback_timer: float = 0.0
var knockback_direction: Vector3 = Vector3.ZERO

@export var speed: float = 5.0
@export var wander_speed: float = 2.0
@export var min_wander_time: float = 2.0
@export var max_wander_time: float = 6.0
@export var aggro_range: float = 12.0
@export var attack_range: float = 1.5
@export var max_hitpoints: int = 75
@export var attack_damage: int = 20

var player: Player
var olive_splat_position: Vector3
var distance_to_player: float
var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value

		change_state(EnemyState.Stagger)
		print(hitpoints)
		#change_state(EnemyState.Provoked)

var current_state: EnemyState
var wander_time: float = 0.0
var wander_direction: Vector3

#var target_angle: float = 0.0 # Desired Y-axis rotation in radians
#var rotation_speed: float = TAU # Radians per second

#@onready var pineapple_mesh: MeshInstance3D = $PineappleMesh
@onready var state_label: Label3D = $StateLabel
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var olive_detector_area_3d: Area3D = $OliveDetectorArea3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_audio_player: AudioStreamPlayer = $HitAudioPlayer
@onready var groan_audio_player: AudioStreamPlayer = $GroanAudioPlayer
@onready var breathing_audio_player_3d: AudioStreamPlayer3D = $BreathingAudioPlayer3D
@onready var pineapple_death_sfx: AudioStreamPlayer3D = $PineappleDeathSFX


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	navigation_agent_3d.navigation_finished.connect(_on_navigation_agent_3d_navigation_finished)
	olive_detector_area_3d.body_entered.connect(_on_olive_detector_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	change_state(EnemyState.Wander)


func change_state(new_state: EnemyState) -> void:
	current_state = new_state
	match current_state:
		EnemyState.Wander:
			if not breathing_audio_player_3d.playing:
				breathing_audio_player_3d.play()
			animation_player.play("float")
			state_label.text = "Wander"
			randomize_wander_variables()
		EnemyState.Alerted:
			if not breathing_audio_player_3d.playing:
				breathing_audio_player_3d.play()
			animation_player.play("pursue")
			state_label.text = "Alerted"
		EnemyState.Investigate:
			if not breathing_audio_player_3d.playing:
				breathing_audio_player_3d.play()
			animation_player.play("float")
			state_label.text = "Investigate"
			investigate_timer = investigate_duration
		EnemyState.Provoked:
			if not breathing_audio_player_3d.playing:
				breathing_audio_player_3d.play()
			state_label.text = "Provoked"
		EnemyState.Stagger:
			breathing_audio_player_3d.stop()
			apply_knockback()
			state_label.text = "Stagger"


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
	
	match current_state:
		EnemyState.Wander:
			velocity = wander_direction * wander_speed
			look_at_target(wander_direction)
			
			if distance_to_player <= aggro_range:
				change_state(EnemyState.Provoked)
		
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
				animation_player.play("attack")
			else:
				animation_player.play("pursue")
	
			var next_position = navigation_agent_3d.get_next_path_position()
			
			var direction = global_position.direction_to(next_position)

			if direction and knockback_timer <= 0.0:
				look_at_target(direction)
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)

			#if knockback_timer > 0.0:
				#velocity += knockback_direction * knockback_force
				#knockback_timer -= delta
		
		EnemyState.Stagger:
			if not hit_audio_player.playing:
				hit_audio_player.play()
			if not groan_audio_player.playing:
				groan_audio_player.play(0.33)
			
			if knockback_timer > 0.0:
				velocity += knockback_direction * knockback_force
				knockback_timer -= delta
			
			if hitpoints <= 0:
				die()

	move_and_slide()


func _on_olive_detector_body_entered(body: Node) -> void:
	if body is OliveProjectile and current_state != EnemyState.Provoked:
		body.splatted.connect(_on_olive_splatted)


func _on_olive_splatted(olive_instance: OliveProjectile) -> void:
	olive_splat_position = olive_instance.global_position
	change_state(EnemyState.Alerted)


func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)


#func smooth_look_at(delta) -> void:
	## Calculate the current Y-axis rotation
	#var current_angle = transform.basis.get_euler().y
	## Smoothly interpolate towards the target angle
	#var new_angle = lerp_angle(current_angle, target_angle, rotation_speed * delta)
	## Apply the new rotation to the object's transform
	#transform.basis = Basis.from_euler(Vector3(transform.basis.get_euler().x, new_angle, transform.basis.get_euler().z))


func randomize_wander_variables() -> void:
	wander_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	wander_time = randf_range(min_wander_time, max_wander_time)


func apply_knockback() -> void:
	animation_player.play("stagger")
	knockback_direction = player.global_position.direction_to(global_position).normalized()
	knockback_direction.y = 0
	knockback_timer = knockback_duration


func attack() -> void:
	player.hitpoints -= attack_damage


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stagger":
		change_state(EnemyState.Provoked)


func _on_navigation_agent_3d_navigation_finished() -> void:
	if current_state == EnemyState.Alerted:
		change_state(EnemyState.Investigate)


func die() -> void:
	pineapple_death_sfx.play()
	pineapple_death_sfx.reparent(get_parent())
	queue_free()
