extends Node2D

class_name WeaponSlot

@export var radius := 30.0          # 武器环绕半径

@onready var weapon: Weapon = $Weapon

var default_position
var _position
var rotation_center
var holder: BaseCharacter

func _ready() -> void:
	_position = position
	default_position = position
	rotation_center = Vector2(0, position.y)
	holder = get_parent().get_parent()
	
func _update_position():
	var offset = rotation_center - _position
	var target_position = rotation_center + offset
	position = target_position
	_position = position
	rotation += deg_to_rad(180)
	if weapon:
		weapon.sprite_2d_weapon.flip_v = !weapon.sprite_2d_weapon.flip_v

func _update_melee_weapon_position():
	if not holder.animaitedSprite2D.is_playing():
		return

	if not holder.hasWeapon():
		return
	
	weapon.set_disable(false)
	
	var position_list: Array[Vector2] = [
		Vector2(4, -24),
		Vector2(18, -25),
		Vector2(18, -25),
		Vector2(31, -24),
		Vector2(31, -24),
		Vector2(24, -21),
	]
	var rotation_list: Array[float] = [
		-75,
		-60,
		-45,
		-15,
		0,
		-30
	]
	
	var frame = holder.animaitedSprite2D.frame
	var p = position_list.get(frame)
	var rotation_degree = rotation_list.get(frame)
	
	var need_flip = holder.attackDirection == "left"
	
	if need_flip:
		p.x = -p.x
		scale.x = -1
		rotation_degree = -rotation_degree
		#scale.y = -1
	else :
		scale.x = 1
		#scale.y = 1
	
	if p:
		position = p
	if rotation_degree:
		rotation_degrees = rotation_degree
	

func show_weapon(character: BaseCharacter):
	visible = true
	if holder.is_using_ranged_weapon():
		if character.attackDirection == "left":
			if position.x > 0:
				_update_position()
		else:
			if position.x < 0:
				_update_position()
	elif holder.is_using_melee_weapon():
		_update_melee_weapon_position()

func hide_weapon():
	visible = false
	position = default_position
