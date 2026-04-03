extends RefCounted

class_name Behavior

var priority: int = 0
var npc: NPC

func _init(npc_ref: NPC):
	npc = npc_ref

func can_start() -> bool:
	return false

func start() -> void:
	pass

func update(delta: float) -> void:
	pass

func end() -> void:
	pass

func get_behavior_name() -> String:
	return "Behavior"
