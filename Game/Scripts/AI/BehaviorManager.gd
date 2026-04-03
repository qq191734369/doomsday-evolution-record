extends RefCounted

class_name BehaviorManager

var npc: NPC
var behaviors: Array[Behavior] = []
var current_behavior: Behavior = null

func _init(npc_ref: NPC):
	npc = npc_ref
	# 添加默认行为
	behaviors.append(AttackBehavior.new(npc))
	behaviors.append(FollowBehavior.new(npc))
	# 后续可以添加采集、做饭等行为

func update(delta: float) -> void:
	# 选择最高优先级的可执行行为
	var best_behavior = find_best_behavior()
	if best_behavior != current_behavior:
		if current_behavior:
			print("切换行为: " + current_behavior.get_behavior_name() + " -> 结束")
			current_behavior.end()
			
		current_behavior = best_behavior
		print("切换行为: " + current_behavior.get_behavior_name() + " -> 开始")
		current_behavior.start()

	if current_behavior:
		current_behavior.update(delta)

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
	behaviors.append(behavior)

func clear_behaviors() -> void:
	if current_behavior:
		current_behavior.end()
		current_behavior = null
	behaviors.clear()
