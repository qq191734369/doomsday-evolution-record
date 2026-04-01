extends Node2D

func _ready() -> void:
	# 光卡无敌人 停止脚本
	if get_child_count() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if get_child_count() == 0:
		GameManager.enemyIsAllDead()
