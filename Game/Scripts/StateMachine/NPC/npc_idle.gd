extends State


func enter():
	super.enter()
	print("NPC enter idle")

func updatePhysics(delta: float):
	super.updatePhysics(delta)


func update():
	super.update()
	
	var c = character as NPC

	# 攻击逻辑
	if c.should_attack():
		# 在攻击范围 直接攻击
		if c.is_in_attack_range():
			parentStateMachine.switchTo("Attack")
		# 不在范围 进入移动状态
		else :
			parentStateMachine.switchTo("Run")
		return

	# 跑动
	if c.in_party == true && c.is_need_adjust_distance_to_target():
		parentStateMachine.switchTo("Run")
		return
	
	if c:
		c.updateAnimation()
