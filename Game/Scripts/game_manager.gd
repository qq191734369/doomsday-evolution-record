extends Node

signal playerHealthUpdated_signal(newValue, maxValue)
signal gameover_signal()

func playerHealthUpdate(newValue: int, maxValue: int):
	emit_signal("playerHealthUpdated_signal", newValue, maxValue)

	
func playerIsDead():
	emit_signal("gameover_signal")

func enemyIsAllDead():
	emit_signal("gameover_signal")
