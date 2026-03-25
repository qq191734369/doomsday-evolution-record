extends State

func enter():
	super.enter()
	character.updateDieAnimation()
	
func update():
	super.update()
	#if character.animaitedSprite2D.frame_progress == 1:
		#queue_free()
