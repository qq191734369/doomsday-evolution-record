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
