extends Node

const GAME_UI_SCENE = preload("res://Game/Scene/Game_UI.tscn")

signal playerHealthUpdated_signal(newValue, maxValue)
signal gameover_signal()

# UI相关
var game_ui_instance: CanvasLayer
var game_ui_manager: Node

# 游戏数据结构
var game_data: Dictionary = {
	"player": {
		"position": Vector2.ZERO,
		"health": 100,
		"max_health": 100,
		"level": 1,
		"experience": 0,
		"current_state": "Idle",
		"inventory": [],
		"equipment": {}
	},
	"npcs": {},  # {npc_id: {name, position, health, in_party, ...}}
	"enemies": {},  # {enemy_id: {type, position, health, ...}}
	"scenes": {
		"current_scene": "",
		"scene_states": {}
	},
	"game_state": {
		"day": 1,
		"time": "08:00",
		"weather": "sunny",
		"completed_quests": [],
		"game_progress": 0
	}
}

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

# 玩家数据管理
func update_player_data(data: Dictionary):
	game_data.player.merge(data)

func get_player_data() -> Dictionary:
	return game_data.player

# NPC数据管理
func add_npc_data(npc_id: String, data: Dictionary):
	game_data.npcs[npc_id] = data

func update_npc_data(npc_id: String, data: Dictionary):
	if npc_id in game_data.npcs:
		game_data.npcs[npc_id].merge(data)

func remove_npc_data(npc_id: String):
	if npc_id in game_data.npcs:
		game_data.npcs.erase(npc_id)

func get_npc_data(npc_id: String) -> Dictionary:
	return game_data.npcs.get(npc_id, {})

func get_all_npc_data() -> Dictionary:
	return game_data.npcs

# 敌人数据管理
func add_enemy_data(enemy_id: String, data: Dictionary):
	game_data.enemies[enemy_id] = data

func update_enemy_data(enemy_id: String, data: Dictionary):
	if enemy_id in game_data.enemies:
		game_data.enemies[enemy_id].merge(data)

func remove_enemy_data(enemy_id: String):
	if enemy_id in game_data.enemies:
		game_data.enemies.erase(enemy_id)

func get_enemy_data(enemy_id: String) -> Dictionary:
	return game_data.enemies.get(enemy_id, {})

func get_all_enemy_data() -> Dictionary:
	return game_data.enemies

# 场景数据管理
func update_scene_data(scene_path: String, data: Dictionary):
	game_data.scenes.scene_states[scene_path] = data

func set_current_scene(scene_path: String):
	game_data.scenes.current_scene = scene_path

func get_current_scene() -> String:
	return game_data.scenes.current_scene

func get_scene_data(scene_path: String) -> Dictionary:
	return game_data.scenes.scene_states.get(scene_path, {})

# 游戏状态管理
func update_game_state(data: Dictionary):
	game_data.game_state.merge(data)

func get_game_state() -> Dictionary:
	return game_data.game_state

# 存档功能
func save_game(slot: int = 1) -> bool:
	var save_path = "user://savegame_" + str(slot) + ".json"
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if not save_file:
		print("无法打开存档文件")
		return false
	
	# 转换数据为可序列化格式
	var save_data = _prepare_save_data()
	
	# 写入文件
	var json_string = JSON.stringify(save_data, "  ")
	save_file.store_string(json_string)
	save_file.close()
	
	print("游戏已保存到槽位 " + str(slot))
	return true

func load_game(slot: int = 1) -> bool:
	var save_path = "user://savegame_" + str(slot) + ".json"
	
	if not FileAccess.file_exists(save_path):
		print("存档文件不存在")
		return false
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if not save_file:
		print("无法打开存档文件")
		return false
	
	# 读取文件
	var json_string = save_file.get_as_string()
	save_file.close()
	
	# 解析JSON
	var json = JSON.parse_string(json_string)
	if typeof(json) != TYPE_DICTIONARY:
		print("存档文件格式错误")
		return false
	
	# 加载数据
	game_data = _restore_save_data(json)
	
	print("游戏已从槽位 " + str(slot) + " 加载")
	return true

# 准备保存数据（处理不可序列化的数据类型）
func _prepare_save_data() -> Dictionary:
	var save_data = game_data.duplicate(true)
	
	# 处理Vector2类型
	if "player" in save_data and "position" in save_data.player:
		save_data.player.position = [save_data.player.position.x, save_data.player.position.y]
	
	# 处理NPC位置
	for npc_id in save_data.npcs.keys():
		if "position" in save_data.npcs[npc_id]:
			save_data.npcs[npc_id].position = [
				save_data.npcs[npc_id].position.x,
				save_data.npcs[npc_id].position.y
			]
	
	# 处理敌人位置
	for enemy_id in save_data.enemies.keys():
		if "position" in save_data.enemies[enemy_id]:
			save_data.enemies[enemy_id].position = [
				save_data.enemies[enemy_id].position.x,
				save_data.enemies[enemy_id].position.y
			]
	
	return save_data

# 恢复保存数据（处理不可序列化的数据类型）
func _restore_save_data(data: Dictionary) -> Dictionary:
	var restore_data = data.duplicate(true)
	
	# 处理Vector2类型
	if "player" in restore_data and "position" in restore_data.player:
		if typeof(restore_data.player.position) == TYPE_ARRAY:
			restore_data.player.position = Vector2(
				restore_data.player.position[0],
				restore_data.player.position[1]
			)
	
	# 处理NPC位置
	for npc_id in restore_data.npcs.keys():
		if "position" in restore_data.npcs[npc_id]:
			if typeof(restore_data.npcs[npc_id].position) == TYPE_ARRAY:
				restore_data.npcs[npc_id].position = Vector2(
					restore_data.npcs[npc_id].position[0],
					restore_data.npcs[npc_id].position[1]
				)
	
	# 处理敌人位置
	for enemy_id in restore_data.enemies.keys():
		if "position" in restore_data.enemies[enemy_id]:
			if typeof(restore_data.enemies[enemy_id].position) == TYPE_ARRAY:
				restore_data.enemies[enemy_id].position = Vector2(
					restore_data.enemies[enemy_id].position[0],
					restore_data.enemies[enemy_id].position[1]
				)
	
	return restore_data

func _exit_tree():
	# 清理Game_UI实例
	if game_ui_instance and game_ui_instance.is_inside_tree():
		game_ui_instance.queue_free()
