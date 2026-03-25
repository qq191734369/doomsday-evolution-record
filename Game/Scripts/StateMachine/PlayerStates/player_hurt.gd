extends State

func enter():
	super.enter()
	if character.knockBackDirection.x < 0:
		character.animaitedSprite2D.flip_h = true
	else:
		character.animaitedSprite2D.flip_h = false
		
	character.updateHurtAnimation()

func update():
	if character.animaitedSprite2D.frame_progress == 1:
		parentStateMachine.switchTo("Idle")

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	
	# 在动画第一帧处理
	if character.animaitedSprite2D.frame == 0:
		character.move_and_collide(character.knockBackDirection * delta * 200)
