extends Node2D

class_name WeaponSlot

@export var radius := 30.0          # 武器环绕半径

@onready var weapon: Weapon = $Weapon

var _position
var rotation_center

func _ready() -> void:
	_position = position
	rotation_center = Vector2(0, position.y)
	
func _update_position():
	var offset = rotation_center - _position
	var target_position = rotation_center + offset
	position = target_position
	_position = position
	rotation += deg_to_rad(180)
	if weapon:
		weapon.sprite_2d_weapon.flip_v = !weapon.sprite_2d_weapon.flip_v

func show_weapon(character: BaseCharacter):
	visible = true
	if character.attackDirection == "left":
		if position.x > 0:
			_update_position()
	else:
		if position.x < 0:
			_update_position()

func hide_weapon():
	visible = false
