extends Node2D

@export var radius := 30.0          # 武器环绕半径

@onready var weapon: Weapon = $Weapon

func _process(_delta):
	if not weapon:
		return
	# 获取鼠标全局坐标
	var mouse_pos = get_global_mouse_position()
	# 获取角色全局坐标
	var slot_pos = global_position
	
	# 计算指向鼠标的方向向量
	var direction = slot_pos.direction_to(mouse_pos)
	
	weapon.position = direction * radius
	# 计算角度（弧度），并旋转武器轴心
	weapon.rotation = direction.angle()
	
	if direction.x < 0:
		weapon.sprite_2d_weapon.flip_v = true
	else :
		weapon.sprite_2d_weapon.flip_v = false
