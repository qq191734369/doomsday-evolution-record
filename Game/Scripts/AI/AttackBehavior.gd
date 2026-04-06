extends Behavior

class_name AttackBehavior

func _init(npc_ref: NPC):
	super(npc_ref)
	priority = 20  # 高优先级，攻击优先于跟随

func can_start() -> bool:
	return npc.in_party and npc.should_attack()

func start() -> void:
	print("开始攻击行为")


func update(_delta: float) -> void:
	# 只有当状态不是Attack或Run时才切换状态
	var current_state = npc.state_machine.getCurrentStateName()
	npc.set_move_target(npc.current_attack_target)
	
	if current_state == "Hurt" or current_state == "Die":
		return

	# 在攻击范围内
	if npc.is_in_attack_range():
		if current_state == "Attack":
			return
		# 检查是否有武器
		if npc.hasWeapon() and npc.weapon:
			npc.state_machine.switchTo("Idle")
			# 使用武器攻击
			npc.attack()
			return
			
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
			npc.state_machine.switchTo("Run")

func end() -> void:
	print("结束攻击行为")

func get_behavior_name() -> String:
	return "Attack"
