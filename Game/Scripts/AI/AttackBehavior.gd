extends Behavior

class_name AttackBehavior

# 后退目标点位
var retreat_position: Vector2

func _init(npc_ref: NPC):
	super(npc_ref)
	priority = 20  # 高优先级，攻击优先于跟随

func can_start() -> bool:
	return npc.in_party and npc.should_attack()

func start() -> void:
	print("开始攻击行为")

func _run_to_follow_target():
	if npc.is_need_adjust_distance_to_target() or npc.is_following():
		npc.set_move_target(npc.follow_target)
		npc.state_machine.switchTo("Run")
	else :
		npc.state_machine.switchTo("Idle")

func update(_delta: float) -> void:
	# 检测最近的敌人并更新攻击目标
	var nearest_enemy = npc.find_nearest_enemy()
	if nearest_enemy:
		npc.current_attack_target = nearest_enemy
	
	# 只有当状态不是Attack或Run时才切换状态
	var current_state = npc.state_machine.getCurrentStateName()
	
	if current_state == "Hurt" or current_state == "Die":
		return

	# 在攻击范围内
	if npc.is_in_attack_range():
		if current_state == "Attack":
			return
		
		# 检查是否有武器
		if npc.hasWeapon() and npc.weapon:
			# 使用武器攻击
			npc.attack()
			
			# 玩家在移动时 只跟玩家走
			if npc.is_following():
				# 一边攻击一边移动
				_run_to_follow_target()
			else :
				# 计算与目标的距离
				var distance = npc.global_position.distance_to(npc.current_attack_target.global_position)
				# 计算攻击范围的一半
				var half_range = npc.get_effective_attack_range() / 2
				
				# 如果距离小于攻击范围的一半，执行放风筝操作
				if distance < half_range and not npc.is_following():
					# 计算后退方向（与目标相反的方向）
					var retreat_direction = (npc.global_position - npc.current_attack_target.global_position).normalized()
					# 设置移动目标为后退位置
					retreat_position = npc.global_position + retreat_direction * 50
					# 直接使用坐标作为移动目标
					npc.set_move_target(retreat_position)
					# 切换到奔跑状态
					npc.state_machine.switchTo("Run")
				else:
					if npc.velocity == Vector2.ZERO:
						# 正常攻击
						npc.state_machine.switchTo("Idle")
				return
		else :	
			npc.state_machine.switchTo("Attack")
	# 不在范围内
	else:
		# 无攻击目标
		if not npc.target:
			npc.state_machine.switchTo("Idle")
			return
		# 还在攻击动画中
		if current_state == "Attack":
			return
		# 走到攻击范围内
		if current_state != "Run":
			npc.set_move_target(npc.current_attack_target)
			npc.state_machine.switchTo("Run")

func end() -> void:
	print("结束攻击行为")

func get_behavior_name() -> String:
	return "Attack"
