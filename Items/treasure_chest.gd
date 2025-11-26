extends Interactable


@export var pickup_item: PackedScene

var player: Player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker_3d: Marker3D = $Marker3D


func _ready() -> void:
	interacted.connect(_on_interacted)
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_interacted(body) -> void:
	if body is Player:
		player = body
		if not is_activated:
			animation_player.play("open")
			is_activated = true


func equip_item() -> void:
	var new_pickup = pickup_item.instantiate()
	new_pickup.position = marker_3d.position
	new_pickup.rotation = marker_3d.rotation
	add_child(new_pickup)
	
	player.weapon_handler.add_inventory(new_pickup.item_name, new_pickup.ammo_type, new_pickup.amount)


func _on_animation_finished(anim_name: StringName) -> void:
	pass
