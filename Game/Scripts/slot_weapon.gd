extends Node2D

@export var radius := 30.0          # 武器环绕半径

@onready var weapon: Weapon = $Weapon

func _process(_delta):
	if not weapon:
		return
	
	# 获取角色全局坐标
	var slot_pos = global_position
	var direction = Vector2.ZERO
	
	# 检测持有者类型
	var holder = get_parent().get_parent()
	if holder is Player:
		# 玩家的武器跟随鼠标
		var mouse_pos = get_global_mouse_position()
		direction = slot_pos.direction_to(mouse_pos)
	elif holder is NPC:
		# NPC的武器指向攻击目标
		if holder.current_attack_target:
			# 有攻击目标时，直接指向攻击目标
			direction = slot_pos.direction_to(holder.current_attack_target.global_position)
		else:
			# 无攻击目标时，指向移动目标（通常是玩家）
			if holder.target:
				direction = slot_pos.direction_to(holder.target.global_position)
			else:
				# 默认方向：向右
				direction = Vector2(1, 0)
	else:
		# 默认行为：跟随鼠标
		var mouse_pos = get_global_mouse_position()
		direction = slot_pos.direction_to(mouse_pos)
	
	var base_angle = direction.angle()
	weapon.position = direction * radius
	weapon.rotation = base_angle
	
	if direction.x < 0:
		weapon.sprite_2d_weapon.flip_v = true
	else :
		weapon.sprite_2d_weapon.flip_v = false
