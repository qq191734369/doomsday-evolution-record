extends Behavior

class_name AttackBehavior

# 后退目标点位
var retreat_position: Vector2

var is_doing_adjust_position: bool = false
var last_adjust_time: float = Time.get_unix_time_from_system()
const ADJUST_STEP: float = 1.0
const ADJUST_TIME_OUT: float = 1.0

var my_timer: Timer

func start_cancelable_timer():
	# 创建一个新的Timer节点
	my_timer = Timer.new()
	my_timer.wait_time = ADJUST_TIME_OUT
	my_timer.one_shot = true
	# 需要添加到当前节点才会开始工作
	npc.add_child(my_timer)
	my_timer.start()
	# 监听timeout信号
	my_timer.timeout.connect(_on_my_timer_timeout)
	print("启动调整位置行为定时器")

func _on_my_timer_timeout():
	print("定时器触发")
	# 触发后清理节点
	my_timer.queue_free()
	is_doing_adjust_position = false

func cancel_timer():
	if my_timer and my_timer.is_inside_tree():
		print("定时器已被取消")
		# 取消后立即清理节点
		my_timer.queue_free()

func _init(npc_ref: NPC):
	super(npc_ref)
	priority = 20  # 高优先级，攻击优先于跟随

func can_start() -> bool:
	return npc.in_party and npc.should_attack()

func start() -> void:
	print("开始攻击行为")
	is_doing_adjust_position = false

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
		if npc.hasWeapon():
			adjust_positon()
		
		if current_state == "Attack":
			return
		
		if is_doing_adjust_position == true:
			return
		
		npc.state_machine.switchTo("Attack")
	# 不在范围内
	else:
		is_doing_adjust_position = false
		# 无攻击目标
		if not npc.target:
			if npc.current_attack_target:
				# 走到攻击范围内
				npc.set_move_target(npc.current_attack_target.global_position)
				npc.state_machine.switchTo("Run")
				return
			npc.state_machine.switchTo("Idle")
			return
		# 还在攻击动画中
		if current_state == "Attack":
			return
		# 走到攻击范围内
		npc.set_move_target(npc.current_attack_target.global_position)
		npc.state_machine.switchTo("Run")


func adjust_positon():
	#if npc.current_attack_target and npc.speed < npc.current_attack_target.speed:
		#is_doing_adjust_position = false
		#return
		
	var current_state = npc.state_machine.getCurrentStateName()

	# 计算与目标的距离
	var distance = npc.global_position.distance_to(npc.current_attack_target.global_position)
	# 计算何时进行走位 躲避怪物
	var min_enemy_distance = maxf(npc.get_effective_attack_range() / 3, 80)
		
	# 如果距离敌人小于一定阈值，执行放风筝操作
	if distance < min_enemy_distance:
		# 调整过于频繁
		if Time.get_unix_time_from_system() - last_adjust_time <= ADJUST_STEP:
			return
		# 计算后退方向（与目标相反的方向）
		var retreat_direction = (npc.global_position - npc.current_attack_target.global_position).normalized()
		# 设置移动目标为后退位置
		retreat_position = npc.global_position + retreat_direction * 50
		# 直接使用坐标作为移动目标
		npc.set_move_target(retreat_position)
		# 切换到奔跑状态
		npc.state_machine.switchTo("Run")
		
		is_doing_adjust_position = true
		last_adjust_time = Time.get_unix_time_from_system()
		print(npc._data.name, "调整距离 开始", last_adjust_time)
		if my_timer and my_timer.is_inside_tree():
			return
		start_cancelable_timer()
	else:
		npc.set_move_target(null)
		is_doing_adjust_position = false
		cancel_timer()
		
		#print(npc._data.name, "调整距离 结束", last_adjust_time)
		if current_state == "Run":
			npc.state_machine.switchTo("Idle")


func attackWithWeapon():
	npc.attack()
	
	# 玩家在移动时 只跟玩家走
	if npc.is_following() and not npc.is_using_melee_weapon():
		# 一边攻击一边移动
		_run_to_follow_target()
	else :
		# 计算与目标的距离
		var distance = npc.global_position.distance_to(npc.current_attack_target.global_position)
		# 计算何时进行走位 躲避怪物
		var min_enemy_distance = maxf(npc.get_effective_attack_range() / 3, 50.0)
		
		# 如果距离小于攻击范围的一半，执行放风筝操作
		if distance < min_enemy_distance and not (npc.is_following() and not npc.is_using_melee_weapon()):
			# 计算后退方向（与目标相反的方向）
			var retreat_direction = (npc.global_position - npc.current_attack_target.global_position).normalized()
			# 设置移动目标为后退位置
			retreat_position = npc.global_position + retreat_direction * 50
			# 直接使用坐标作为移动目标
			npc.set_move_target(retreat_position)
			# 切换到奔跑状态
			npc.state_machine.switchTo("Run")
		else:
			npc.set_move_target(null)
			# 正常攻击
			npc.state_machine.switchTo("Idle")
		
				

func end() -> void:
	print("结束攻击行为")

func get_behavior_name() -> String:
	return "Attack"
