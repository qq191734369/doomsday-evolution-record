extends Node2D

func _ready():
	# 获取传送点
	var teleport_to_test = get_node_or_null("Level/TeleportToTest")
	if teleport_to_test:
		# 连接进入区域信号
		teleport_to_test.body_entered.connect(_on_teleport_to_test_entered)

func _on_teleport_to_test_entered(body):
	# 检查是否是玩家
	if body.name == "Player":
		print("玩家进入传送点，前往测试场景")
		# 切换到TestScene场景
		get_tree().change_scene_to_file("res://Game/Scene/TestScene.tscn")
