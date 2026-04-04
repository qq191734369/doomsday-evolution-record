extends State


func enter():
	super.enter()
	#print("NPC enter idle")

func updatePhysics(delta: float):
	super.updatePhysics(delta)


func update():
	super.update()
	
	var c = character as NPC

	# 行为逻辑由行为管理器处理
	# Idle状态只负责动画更新
	if c:
		c.updateAnimation()
