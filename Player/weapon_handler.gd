extends Node3D


@export var weapon_1: Node3D
@export var weapon_2: Node3D

var current_weapon: Node3D


func _ready() -> void:
	equip(weapon_1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_1"):
		equip(weapon_1)
	elif event.is_action_pressed("weapon_2"):
		equip(weapon_2)
	elif event.is_action_pressed("next_weapon"):
		change_weapon(1)
	elif event.is_action_pressed("previous_weapon"):
		change_weapon(-1)


func equip(active_weapon: Node3D) -> void:
	for child in get_children():
		if child == active_weapon:
			child.visible = true
			child.set_process(true)
			child.ammo_handler.update_ammo_label(child.ammo_type)
		else:
			child.visible = false
			child.set_process(false)
	
	current_weapon = active_weapon


func change_weapon(index_modifier: int) -> void:
	var index = get_current_index()
	index = wrapi(index + index_modifier, 0, get_child_count())
	equip(get_child(index))


func get_current_index() -> int:
	for index in get_child_count():
		if get_child(index).visible:
			return index
	return 0


func get_weapon_ammo() -> AmmoHandler.ammo_type:
	return get_child(get_current_index()).ammo_type


"""
class_name WeaponManager
extends Node3D


var _weapons: Array[Weapon]
var _current_weapon: Weapon = null
var _current_weapon_id: int:
	set(value):
		_current_weapon_id = wrapi(value, 0, _weapons.size())
		_equip()


func _ready() -> void:
	for weapon in self.get_children():
		if weapon is Weapon:
			_weapons.append(weapon)
			weapon.visible = false
			weapon.set_process(false)

	_current_weapon_id = 0


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_num_select"):
		_current_weapon_id = event.keycode - 49 # 49 is ascii code for 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_select_up"):
		_current_weapon_id += 1
		
	if event.is_action_pressed("weapon_select_down"):
		_current_weapon_id -= 1


func _equip() -> void:
	# hide current weapon
	if _current_weapon != null:
		_current_weapon.visible = false
		_current_weapon.set_process(false)
	
	# equip new weapon
	_current_weapon = _weapons[_current_weapon_id]
	_current_weapon.visible = true
	_current_weapon.set_process(true)
	"""
