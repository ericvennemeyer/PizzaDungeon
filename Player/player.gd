class_name Player
extends CharacterBody3D


@export var speed: float = 6.0
@export var jump_height: float = 1.0
@export var fall_multiplier: float = 2.5
@export var max_hitpoints: int = 100
@export var aim_multiplier: float = 0.7

var mouse_motion: Vector2 = Vector2.ZERO
var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_animation_player.stop(false)
			damage_animation_player.play("TakeDamage")
		hitpoints = value
		health_progress_bar.value = hitpoints
		if hitpoints <= 0:
			game_over_menu.game_over()
var weapon_zoom_speed: float = 20.0


@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer
@onready var game_over_menu: Control = $GameOverMenu
@onready var ammo_handler: AmmoHandler = %AmmoHandler
@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var weapon_camera: Camera3D = %WeaponCamera
@onready var smooth_camera_fov := smooth_camera.fov
@onready var weapon_camera_fov := weapon_camera.fov
@onready var health_progress_bar: ProgressBar = $MarginContainer/HealthProgressBar
@onready var weapon_handler: Node3D = %WeaponHandler
@onready var interaction_ray_cast: RayCast3D = $CameraPivot/SmoothCamera/InteractionRayCast
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	health_progress_bar.value = hitpoints
	# Switching mouse mode is now handled in _input so it will work with web build
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = lerp(
			smooth_camera.fov, 
			smooth_camera_fov * aim_multiplier, 
			delta * weapon_zoom_speed
			)
		weapon_camera.fov = lerp(
			weapon_camera.fov, 
			weapon_camera_fov * aim_multiplier, 
			delta * weapon_zoom_speed
			)
	else:
		smooth_camera.fov = lerp(
			smooth_camera.fov, 
			smooth_camera_fov, 
			delta * weapon_zoom_speed * 1.5
			)
		weapon_camera.fov = lerp(
			weapon_camera.fov, 
			weapon_camera_fov, 
			delta * weapon_zoom_speed * 1.5
			)


func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * fall_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * -get_gravity().y)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not audio_stream_player.playing:
			audio_stream_player.play()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("aim"):
			velocity.x *= aim_multiplier
			velocity.y *= aim_multiplier
	else:
		audio_stream_player.stop()
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# This If statement came from a Reddit post re: how to capture mouse movement in web build
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# End Reddit code
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * 0.001
		if Input.is_action_pressed("aim"):
			mouse_motion *= aim_multiplier


func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO
