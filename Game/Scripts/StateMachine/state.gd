extends Node

class_name State

var parentStateMachine: StateMachine
var character: BaseCharacter

func updatePhysics(delta: float):
	pass
	
func update():
	if parentStateMachine.debug_label:
		if character.showDebuggVisual:
			_updateDebugText()
		else:
			parentStateMachine.debug_label.visible = false

func enter():
	pass

func exit():
	pass
	
func ready():
	pass
	
func _updateDebugText():
	parentStateMachine.debug_label.visible = true
	parentStateMachine.debug_label.text = name + '/' + str(character.currentHealth)
	if character is NPC:
		var behavior = character.behavior_manager.get_current_behavior()
		if behavior:
			parentStateMachine.debug_label.text = parentStateMachine.debug_label.text + '\n' + behavior.get_behavior_name()
