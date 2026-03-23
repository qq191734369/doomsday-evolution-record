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
