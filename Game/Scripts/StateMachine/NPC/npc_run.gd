extends State

func update_follow_state(delta: float):
	var currentCharacter = character as NPC
	
	# 跟随逻辑
	if not currentCharacter.in_party or not currentCharacter.follow_target:
		parentStateMachine.switchTo("Idle")
		return
	
	var dir = currentCharacter.get_direction_to_follow_target()
	if currentCharacter.is_exceeds_following_distance():
		currentCharacter.velocity = dir * currentCharacter.speed
	elif currentCharacter.is_less_than_min_following_distance():
		currentCharacter.velocity = -dir * currentCharacter.speed * 0.5
	else:
		currentCharacter.velocity = currentCharacter.velocity.lerp(Vector2.ZERO, 0.2)
		# 如果达到跟随距离内 且 家还在行走状态 则维持行走
		if currentCharacter.follow_target.state_machine.getCurrentStateName() == "Run":
			pass
		else:
			parentStateMachine.switchTo("Idle")
	
	currentCharacter.move_and_slide()

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	update_follow_state(delta)


func update():
	super.update()
	character.updateAnimation()
	
