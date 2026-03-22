extends Node

class_name State

var parentStateMachine: StateMachine
var character: BaseCharacter

func updatePhysics(delta: float):
	pass
	
func update():
	if parentStateMachine.debug_label:
		if character.showDebuggVisual:
			parentStateMachine.debug_label.text = name
			parentStateMachine.debug_label.visible = true
		else:
			parentStateMachine.debug_label.visible = false

func enter():
	pass

func exit():
	pass
	
func ready():
	pass
