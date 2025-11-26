class_name AmmoHandler
extends Node


@export var ammo_label: Label
@export var weapon_handler: Node3D


enum ammo_type {
	OLIVE,
	NONE
}

var ammo_storage: Dictionary[int, int] = {
	ammo_type.OLIVE: 10,
	ammo_type.NONE: 0
}


func _ready() -> void:
	ammo_label.visible = false


func has_ammo(type: ammo_type) -> bool:
	return ammo_storage[type] > 0


func use_ammo(type: ammo_type) -> void:
	if has_ammo(type):
		ammo_storage[type] -= 1
		update_ammo_label(weapon_handler.get_weapon_ammo())


func add_ammo(type: ammo_type, amount: int) -> void:
	ammo_storage[type] += amount
	update_ammo_label(weapon_handler.get_weapon_ammo())


func update_ammo_label(type: ammo_type) -> void:
	if type == ammo_type.OLIVE:
		ammo_label.visible = true
		ammo_label.text = str(ammo_storage[type])
	else:
		ammo_label.visible = false
