extends State

func enter():
	super.enter()

func updatePhysics(delta: float):
	super.updatePhysics(delta)

	character.velocity = character.inputDirection * character.data.speed * delta * 50
	character.move_and_slide()

func update():
	super.update()
	character.updateAnimation()
	
	# 对话开启时不响应攻击
	if not DialogManager.is_active:
		if Input.is_action_pressed("attack"):
			if character.hasWeapon():
				character.start_attack()
			else :
				parentStateMachine.switchTo("Attack")
		elif Input.is_action_just_released("attack"):
			if character.hasWeapon():
				character.stop_attack()
	
	if character.inputDirection == Vector2.ZERO:
		parentStateMachine.switchTo("Idle")
		return
