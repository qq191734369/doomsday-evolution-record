extends RefCounted

class_name BehaviorManager

var npc: NPC
var behaviors: Array[Behavior] = []
var current_behavior: Behavior = null
# 当前最优先行为，如果有则先执行这一行为
var the_most_important_behavior: Behavior
# 行为检测频率控制
var behavior_check_timer: float = 0.0
var behavior_check_interval: float = 0.05  # 每0.1秒检查一次行为


func _init(npc_ref: NPC):
	npc = npc_ref
	# 添加默认行为
	add_behavior(AttackBehavior.new(npc))
	add_behavior(FollowBehavior.new(npc))
	# 后续可以添加采集、做饭等行为

func update(delta: float) -> void:
	# 更新行为检测定时器
	behavior_check_timer += delta
	
	# 只有当定时器达到间隔时间时才进行行为检测
	if behavior_check_timer >= behavior_check_interval:
		# 重置定时器
		behavior_check_timer = 0.0
		
		# 选择最高优先级的可执行行为
		var behaviorRes = find_behavior()
		var normal = behaviorRes["best_behavior"] as Behavior
		var important = behaviorRes["most_important_behavior"] as Behavior
		
		_update_the_most_important_behavior(important)

		var best_behavior = the_most_important_behavior if the_most_important_behavior else normal
		if not best_behavior:
			return
		if best_behavior != current_behavior:
			if current_behavior:
				#print("切换行为: " + current_behavior.get_behavior_name() + " -> 结束")
				current_behavior.end()
				
			current_behavior = best_behavior
			#print("切换行为: " + current_behavior.get_behavior_name() + " -> 开始")
			current_behavior.start()
	
	# 无论是否检测行为，都更新当前行为
	if current_behavior:
		current_behavior.update(delta)
		
func _update_the_most_important_behavior(important: Behavior):
	if important:
		if the_most_important_behavior:
			if the_most_important_behavior.preempt_priority < important.preempt_priority:
				the_most_important_behavior = important
		else :
			the_most_important_behavior = important
	
	if the_most_important_behavior:
		if the_most_important_behavior.is_most_important_done():
			the_most_important_behavior = null
	
		
func find_behavior() -> Dictionary:
	var best_behavior = null
	var best_priority = -1
	var most_important_behavior = null
	var important_priority = -1

	for behavior in behaviors:
		if behavior.can_start():
			if behavior.priority > best_priority:
				best_behavior = behavior
				best_priority = behavior.priority
			if behavior.is_most_important() and behavior.preempt_priority > important_priority:
				important_priority = behavior.preempt_priority
				most_important_behavior = behavior
				
	return {
		"best_behavior": best_behavior,
		"most_important_behavior": most_important_behavior
	}

func find_best_behavior() -> Behavior:
	var best_behavior = null
	var best_priority = -1

	for behavior in behaviors:
		if behavior.can_start() and behavior.priority > best_priority:
			best_behavior = behavior
			best_priority = behavior.priority

	return best_behavior

func get_current_behavior() -> Behavior:
	return current_behavior

func add_behavior(behavior: Behavior) -> void:
	behavior.parentManager = self
	behaviors.append(behavior)

func clear_behaviors() -> void:
	if current_behavior:
		current_behavior.end()
		current_behavior = null
	behaviors.clear()
