extends Node

const GAME_UI_SCENE = preload("res://Game/Scene/Game_UI.tscn")

signal playerHealthUpdated_signal(newValue, maxValue)
signal gameover_signal()

# UI相关
var game_ui_instance: CanvasLayer
var game_ui_manager: GameUI

func _ready() -> void:
	# 动态创建Game_UI实例
	create_game_ui()

func create_game_ui():
	# 检查是否已经存在实例
	if game_ui_instance:
		return
	
	# 实例化Game_UI场景
	game_ui_instance = GAME_UI_SCENE.instantiate() as CanvasLayer
	
	# 添加到根节点
	get_tree().root.add_child.call_deferred(game_ui_instance)
	
	# 获取game_ui_manager脚本实例
	game_ui_manager = game_ui_instance

func show_game_ui():
	if game_ui_instance:
		game_ui_instance.visible = true

func hide_game_ui():
	if game_ui_instance:
		game_ui_instance.visible = false

func get_game_ui_manager() -> Node:
	return game_ui_manager

func playerHealthUpdate(newValue: int, maxValue: int):
	emit_signal("playerHealthUpdated_signal", newValue, maxValue)

func playerIsDead():
	emit_signal("gameover_signal")

func enemyIsAllDead():
	emit_signal("gameover_signal")


func _exit_tree():
	# 清理Game_UI实例
	if game_ui_instance and game_ui_instance.is_inside_tree():
		game_ui_instance.queue_free()
