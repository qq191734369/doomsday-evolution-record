extends State

func enter():
	super.enter()
	character.updateHurtAnimation()

func update():
	super.update()
	
	var animationSprite2D = character.animaitedSprite2D
	if animationSprite2D.frame_progress == 1:
		parentStateMachine.switchTo("Idle")
		
func updatePhysics(delta: float):
	super.updatePhysics(delta)
	# 在动画第一帧处理
	if character.animaitedSprite2D.frame == 0:
		character.move_and_collide(character.knockBackDirection * delta * 50)
