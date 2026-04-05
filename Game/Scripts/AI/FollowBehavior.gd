extends Behavior

class_name FollowBehavior

func _init(npc_ref: NPC):
	super(npc_ref)
	priority = 10  # 中等优先级，低于攻击

func can_start() -> bool:
	return npc.in_party and npc.follow_target
	
func is_most_important():
	return npc.is_outof_max_follow_range()
	
func is_most_important_done():
	return not npc.is_need_adjust_distance_to_target()

func start() -> void:
	print("开始跟随行为")
	# 设置目标为玩家角色
	npc.set_move_target(npc.follow_target)

func update(delta: float) -> void:
	# 只有当状态需要切换时才切换
	var current_state = npc.state_machine.getCurrentStateName()
	if npc.is_need_adjust_distance_to_target():
		if current_state != "Run":
			npc.state_machine.switchTo("Run")
	else:
		# 如果达到跟随距离内 且 玩家还在行走状态 则维持行走
		if npc.follow_target.state_machine.getCurrentStateName() == "Run":
			return
		if current_state != "Idle":
			npc.state_machine.switchTo("Idle")

func end() -> void:
	print("结束跟随行为")

func get_behavior_name() -> String:
	return "Follow"
