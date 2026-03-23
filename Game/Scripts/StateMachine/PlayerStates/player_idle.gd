extends State


func updatePhysics(delta: float):
	super.updatePhysics(delta)
	

func update():
	super.update()
	
	if character:
		character.updateAnimation()

	if character.inputDirection.length() > 0:
		parentStateMachine.switchTo("Run")
		return
	
	if Input.is_action_just_pressed("attack"):
		parentStateMachine.switchTo("Attack")
		return
