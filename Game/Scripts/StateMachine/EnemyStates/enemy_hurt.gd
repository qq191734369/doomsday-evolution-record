extends State

func enter():
	super.enter()
	character.updateHurtAnimation()

func update():
	super.update()
	
	var animationSprite2D = character.animaitedSprite2D as AnimatedSprite2D
	if animationSprite2D.frame_progress == 1:
		parentStateMachine.switchTo("Idle")
