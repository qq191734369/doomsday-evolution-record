extends State

func update():
	super.update()
	if character.global_position.distance_to((character.player as BaseCharacter).global_position) > character.playerDetectionRadius:
		parentStateMachine.switchTo("Idle")
