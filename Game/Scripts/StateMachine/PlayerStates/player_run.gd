extends State

func updatePhysics(delta: float):
	super.updatePhysics(delta)

	character.velocity = character.inputDirection * character.speed
	character.move_and_slide()

func update():
	super.update()
	character.updateAnimation()
	
	if Input.is_action_just_pressed("attack"):
		parentStateMachine.switchTo("Attack")
		return
	
	if character.inputDirection == Vector2.ZERO:
		parentStateMachine.switchTo("Idle")
		return
