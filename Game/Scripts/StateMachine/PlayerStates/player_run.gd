extends State

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	if character.inputDirection == Vector2.ZERO:
		parentStateMachine.switchTo("Idle")
		return

	character.velocity = character.inputDirection * character.speed
	character.move_and_slide()

func update():
	super.update()
	character.updateAnimation()
