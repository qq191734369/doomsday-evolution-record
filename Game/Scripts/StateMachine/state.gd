extends Node

class_name State

var parentStateMachine: StateMachine
var character: BaseCharacter

func updatePhysics(delta: float):
	pass
	
func update():
	if parentStateMachine:
		parentStateMachine.debug_label.text = name

func enter():
	print("state enter " + name)
	pass

func exit():
	print("state exit " + name)
	pass
	
func ready():
	pass
