extends RefCounted

class_name Behavior

# 抢占优先级
var preempt_priority: int = 0
# 优先级
var priority: int = 0
var npc: NPC
var parentManager: BehaviorManager

func _init(npc_ref: NPC):
	npc = npc_ref

func can_start() -> bool:
	return false

func is_most_important():
	return false

func is_most_important_done():
	return true

func start() -> void:
	pass

func update(_delta: float) -> void:
	pass

func end() -> void:
	pass

func get_behavior_name() -> String:
	return "Behavior"
