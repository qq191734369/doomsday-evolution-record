extends State

var is_running_to_player = false

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	var c = character as NPC
	
	# 有攻击目标 并且 没有跑向玩家才像攻击目标跑
	if c.current_attack_target and not is_running_to_player:
		run_to_attack_target(delta)
	else :
		update_follow_state(delta)
	

func update():
	super.update()
	character.updateAnimation()


func run_to_attack_target(delta):
	var c = character as NPC
	
	if not c:
		return
	
	if not c.should_attack():
		update_follow_state(delta)
		return
		
	
	if c.is_in_attack_range():  # 攻击距离
		# 执行攻击
		parentStateMachine.switchTo("Attack")
	else:
		# 移动到攻击位置
		var direction = c.global_position.direction_to(c.current_attack_target.global_position)
		c.velocity = direction * c.speed
		c.move_and_slide()




func update_follow_state(delta: float):
	is_running_to_player = true
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
		# 如果达到跟随距离内 且 玩家还在行走状态 则维持行走
		if currentCharacter.follow_target.state_machine.getCurrentStateName() == "Run":
			pass
		else:
			is_running_to_player = false
			parentStateMachine.switchTo("Idle")
	
	currentCharacter.move_and_slide()
