extends State


func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	if character.inputDirection.length() > 0:
		parentStateMachine.switchTo("Run")

func update():
	super.update()
	character.updateAnimation()
