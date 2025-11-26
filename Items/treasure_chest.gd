extends Interactable


@export var pickup_item: PackedScene

var is_open: bool = false
var player: Player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker_3d: Marker3D = $Marker3D


func _ready() -> void:
	interacted.connect(_on_interacted)


func _on_interacted(body) -> void:
	if body is Player:
		player = body
		if not is_open:
			animation_player.play("open")
			is_open = true


func equip_item() -> void:
	var new_pickup = pickup_item.instantiate()
	new_pickup.position = marker_3d.position
	new_pickup.rotation = marker_3d.rotation
	add_child(new_pickup)
	
	player.weapon_handler.add_inventory(new_pickup.item_name, new_pickup.ammo_type, new_pickup.amount)
