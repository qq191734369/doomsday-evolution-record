extends Node2D

func _ready():
	# 获取传送点
	var teleport_back = get_node_or_null("Level/TeleportBack")
	if teleport_back:
		# 连接进入区域信号
		teleport_back.body_entered.connect(_on_teleport_back_entered)

func _on_teleport_back_entered(body):
	# 检查是否是玩家
	if body.name == "Player":
		print("玩家进入传送点，返回Main场景")
		# 切换回Main场景
		get_tree().change_scene_to_file("res://Game/Scene/Main.tscn")
