extends Node

# 游戏数据
var game_data: GameData

# 初始化
func _ready() -> void:
	# 获取GameData实例
	game_data = GameData.get_instance()

# 获取游戏数据
func get_game_data() -> GameData:
	return game_data

# 获取玩家数据
func get_player_data() -> GameData.CharacterInfo:
	return game_data.player

# 更新玩家数据
func update_player_data(data: Dictionary):
	game_data.update_player_data(data)

# 保存游戏
func save_game(slot: int = 1) -> bool:
	var save_path = "user://savegame_" + str(slot) + ".json"
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if not save_file:
		print("无法打开存档文件")
		return false
	
	# 转换数据为可序列化格式
	var save_data = game_data.to_serializable()
	
	# 写入文件
	var json_string = JSON.stringify(save_data, "  ")
	save_file.store_string(json_string)
	save_file.close()
	
	print("游戏已保存到槽位 " + str(slot))
	return true

# 加载游戏
func load_game(slot: int = 1) -> bool:
	var save_path = "user://savegame_" + str(slot) + ".json"
	
	if not FileAccess.file_exists(save_path):
		print("存档文件不存在")
		return false
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if not save_file:
		print("无法打开存档文件")
		return false
	
	var json_string = save_file.get_as_string()
	save_file.close()
	
	var json = JSON.parse_string(json_string)
	if json is Dictionary:
		game_data.from_serializable(json)
		print("游戏已从槽位 " + str(slot) + " 加载")
		return true
	else:
		print("存档文件格式错误")
		return false
