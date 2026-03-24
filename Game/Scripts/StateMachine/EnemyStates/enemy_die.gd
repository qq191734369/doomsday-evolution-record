extends State

func enter():
	super.enter()
	character.updateDieAnimation()
	
func update():
	super.update()
	# 移除节点
	var animatedSprite2D = character.animaitedSprite2D as AnimatedSprite2D
	if animatedSprite2D.frame_progress == 1:
		character.queue_free()

func updatePhysics(delta: float):
	super.updatePhysics(delta)
	# 在动画第一帧处理
	if character.animaitedSprite2D.frame == 0:
		character.move_and_collide(character.knockBackDirection * delta * 200)
