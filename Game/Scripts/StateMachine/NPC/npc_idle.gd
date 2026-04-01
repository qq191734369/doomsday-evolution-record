extends State


func updatePhysics(delta: float):
	super.updatePhysics(delta)
	

func update():
	super.update()
	
	var c = character as NPC
	
	if c:
		c.updateAnimation()

	# 跑动
	if c.in_party == true && c.is_need_adjust_distance_to_target():
		parentStateMachine.switchTo("Run")
	
	# 攻击
