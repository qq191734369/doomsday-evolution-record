class_name GameData

# 单例实例
static var singleton: GameData

class PlayerInfo:
	var maxHealth: int = 100
	var currentHealth: int = 100
	var attackDamage: int = 50
	var speed: int = 200
	var position: Vector2 = Vector2.ZERO
	var name: String = "Player"
	var level: int = 1
	var experience: int = 0
	var inventory: Array = []
	var equipment: Dictionary = {}
	var currentState: String = "Idle"

class NPCInfo:
	var maxHealth: int = 100
	var currentHealth: int = 100
	var attackDamage: int = 30
	var speed: int = 180
	var position: Vector2 = Vector2.ZERO
	var name: String = "NPC"
	var scene: String = ""
	var inParty: bool = false
	var dialogueId: String = ""

class EnemyInfo:
	var maxHealth: int = 80
	var currentHealth: int = 80
	var attackDamage: int = 20
	var speed: int = 150
	var position: Vector2 = Vector2.ZERO
	var type: String = "Zombie"
	var scene: String = ""

class SceneInfo:
	var name: String = ""
	var enemies: Array = []
	var npcs: Array = []
	var state: Dictionary = {}

class GameStateInfo:
	var day: int = 1
	var time: String = "08:00"
	var weather: String = "sunny"
	var completedQuests: Array = []
	var gameProgress: int = 0
	var currentScene: String = ""

# 玩家信息
var player: PlayerInfo = PlayerInfo.new()

# npc信息
var npcDictionary: Dictionary[String, NPCInfo] = {}
# 第一个为玩家
var partyList: Array = []

# 敌人信息
var enemyDictionary: Dictionary[String, EnemyInfo] = {}

# 场景信息
var sceneDictionary: Dictionary[String, SceneInfo] = {}

# 游戏状态
var gameState: GameStateInfo = GameStateInfo.new()

# 单例方法
static func get_instance() -> GameData:
	if not GameData.singleton:
		GameData.singleton = GameData.new()
		GameData.singleton._initialize()
	return GameData.singleton

# 初始化
func _initialize():
	player = PlayerInfo.new()
	gameState = GameStateInfo.new()

# 玩家数据管理
func update_player_data(data: Dictionary):
	if player:
		for key in data.keys():
			if player.has(key):
				player[key] = data[key]

func get_player_data() -> PlayerInfo:
	return player

# NPC数据管理
func add_npc_data(npc_id: String, data: Dictionary):
	var npc_info = NPCInfo.new()
	for key in data.keys():
		if npc_info.has(key):
			npc_info[key] = data[key]
	npcDictionary[npc_id] = npc_info

func update_npc_data(npc_id: String, data: Dictionary):
	if npc_id in npcDictionary:
		var npc_info = npcDictionary[npc_id]
		for key in data.keys():
			if npc_info.has(key):
				npc_info[key] = data[key]

func remove_npc_data(npc_id: String):
	if npc_id in npcDictionary:
		npcDictionary.erase(npc_id)

func get_npc_data(npc_id: String) -> NPCInfo:
	return npcDictionary.get(npc_id, null)

func get_all_npc_data() -> Dictionary:
	return npcDictionary

# 敌人数据管理
func add_enemy_data(enemy_id: String, data: Dictionary):
	var enemy_info = EnemyInfo.new()
	for key in data.keys():
		if enemy_info.has(key):
			enemy_info[key] = data[key]
	enemyDictionary[enemy_id] = enemy_info

func update_enemy_data(enemy_id: String, data: Dictionary):
	if enemy_id in enemyDictionary:
		var enemy_info = enemyDictionary[enemy_id]
		for key in data.keys():
			if enemy_info.has(key):
				enemy_info[key] = data[key]

func remove_enemy_data(enemy_id: String):
	if enemy_id in enemyDictionary:
		enemyDictionary.erase(enemy_id)

func get_enemy_data(enemy_id: String) -> EnemyInfo:
	return enemyDictionary.get(enemy_id, null)

func get_all_enemy_data() -> Dictionary:
	return enemyDictionary

# 场景数据管理
func add_scene_data(scene_name: String, data: Dictionary):
	var scene_info = SceneInfo.new()
	for key in data.keys():
		if scene_info.has(key):
			scene_info[key] = data[key]
	sceneDictionary[scene_name] = scene_info

func update_scene_data(scene_name: String, data: Dictionary):
	if scene_name in sceneDictionary:
		var scene_info = sceneDictionary[scene_name]
		for key in data.keys():
			if scene_info.has(key):
				scene_info[key] = data[key]

func get_scene_data(scene_name: String) -> SceneInfo:
	return sceneDictionary.get(scene_name, null)

# 游戏状态管理
func update_game_state(data: Dictionary):
	if gameState:
		for key in data.keys():
			if gameState.has(key):
				gameState[key] = data[key]

func get_game_state() -> GameStateInfo:
	return gameState

# 队伍管理
func add_to_party(member_id: String):
	if not partyList.has(member_id):
		partyList.append(member_id)

func remove_from_party(member_id: String):
	if partyList.has(member_id):
		partyList.erase(member_id)

func get_party_members() -> Array:
	return partyList

# 转换为可序列化格式
func to_serializable() -> Dictionary:
	var data = {
		"player": _serialize_player(),
		"npcs": _serialize_npcs(),
		"enemies": _serialize_enemies(),
		"scenes": _serialize_scenes(),
		"gameState": _serialize_game_state(),
		"partyList": partyList
	}
	return data

# 从序列化格式加载
func from_serializable(data: Dictionary):
	if "player" in data:
		_deserialize_player(data["player"])
	if "npcs" in data:
		_deserialize_npcs(data["npcs"])
	if "enemies" in data:
		_deserialize_enemies(data["enemies"])
	if "scenes" in data:
		_deserialize_scenes(data["scenes"])
	if "gameState" in data:
		_deserialize_game_state(data["gameState"])
	if "partyList" in data:
		partyList = data["partyList"]

# 序列化方法
func _serialize_player() -> Dictionary:
	var data = {
		"maxHealth": player.maxHealth,
		"currentHealth": player.currentHealth,
		"attackDamage": player.attackDamage,
		"speed": player.speed,
		"position": [player.position.x, player.position.y],
		"name": player.name,
		"level": player.level,
		"experience": player.experience,
		"inventory": player.inventory,
		"equipment": player.equipment,
		"currentState": player.currentState
	}
	return data

func _serialize_npcs() -> Dictionary:
	var data = {}
	for npc_id in npcDictionary.keys():
		var npc = npcDictionary[npc_id]
		data[npc_id] = {
			"maxHealth": npc.maxHealth,
			"currentHealth": npc.currentHealth,
			"attackDamage": npc.attackDamage,
			"speed": npc.speed,
			"position": [npc.position.x, npc.position.y],
			"name": npc.name,
			"scene": npc.scene,
			"inParty": npc.inParty,
			"dialogueId": npc.dialogueId
		}
	return data

func _serialize_enemies() -> Dictionary:
	var data = {}
	for enemy_id in enemyDictionary.keys():
		var enemy = enemyDictionary[enemy_id]
		data[enemy_id] = {
			"maxHealth": enemy.maxHealth,
			"currentHealth": enemy.currentHealth,
			"attackDamage": enemy.attackDamage,
			"speed": enemy.speed,
			"position": [enemy.position.x, enemy.position.y],
			"type": enemy.type,
			"scene": enemy.scene
		}
	return data

func _serialize_scenes() -> Dictionary:
	var data = {}
	for scene_name in sceneDictionary.keys():
		var scene = sceneDictionary[scene_name]
		data[scene_name] = {
			"name": scene.name,
			"enemies": scene.enemies,
			"npcs": scene.npcs,
			"state": scene.state
		}
	return data

func _serialize_game_state() -> Dictionary:
	var data = {
		"day": gameState.day,
		"time": gameState.time,
		"weather": gameState.weather,
		"completedQuests": gameState.completedQuests,
		"gameProgress": gameState.gameProgress,
		"currentScene": gameState.currentScene
	}
	return data

# 反序列化方法
func _deserialize_player(data: Dictionary):
	player.maxHealth = data.get("maxHealth", 100)
	player.currentHealth = data.get("currentHealth", 100)
	player.attackDamage = data.get("attackDamage", 50)
	player.speed = data.get("speed", 200)
	if "position" in data and data["position"] is Array:
		player.position = Vector2(data["position"][0], data["position"][1])
	player.name = data.get("name", "Player")
	player.level = data.get("level", 1)
	player.experience = data.get("experience", 0)
	player.inventory = data.get("inventory", [])
	player.equipment = data.get("equipment", {})
	player.currentState = data.get("currentState", "Idle")

func _deserialize_npcs(data: Dictionary):
	npcDictionary.clear()
	for npc_id in data.keys():
		var npc_data = data[npc_id]
		var npc_info = NPCInfo.new()
		npc_info.maxHealth = npc_data.get("maxHealth", 100)
		npc_info.currentHealth = npc_data.get("currentHealth", 100)
		npc_info.attackDamage = npc_data.get("attackDamage", 30)
		npc_info.speed = npc_data.get("speed", 180)
		if "position" in npc_data and npc_data["position"] is Array:
			npc_info.position = Vector2(npc_data["position"][0], npc_data["position"][1])
		npc_info.name = npc_data.get("name", "NPC")
		npc_info.scene = npc_data.get("scene", "")
		npc_info.inParty = npc_data.get("inParty", false)
		npc_info.dialogueId = npc_data.get("dialogueId", "")
		npcDictionary[npc_id] = npc_info

func _deserialize_enemies(data: Dictionary):
	enemyDictionary.clear()
	for enemy_id in data.keys():
		var enemy_data = data[enemy_id]
		var enemy_info = EnemyInfo.new()
		enemy_info.maxHealth = enemy_data.get("maxHealth", 80)
		enemy_info.currentHealth = enemy_data.get("currentHealth", 80)
		enemy_info.attackDamage = enemy_data.get("attackDamage", 20)
		enemy_info.speed = enemy_data.get("speed", 150)
		if "position" in enemy_data and enemy_data["position"] is Array:
			enemy_info.position = Vector2(enemy_data["position"][0], enemy_data["position"][1])
		enemy_info.type = enemy_data.get("type", "Zombie")
		enemy_info.scene = enemy_data.get("scene", "")
		enemyDictionary[enemy_id] = enemy_info

func _deserialize_scenes(data: Dictionary):
	sceneDictionary.clear()
	for scene_name in data.keys():
		var scene_data = data[scene_name]
		var scene_info = SceneInfo.new()
		scene_info.name = scene_data.get("name", "")
		scene_info.enemies = scene_data.get("enemies", [])
		scene_info.npcs = scene_data.get("npcs", [])
		scene_info.state = scene_data.get("state", {})
		sceneDictionary[scene_name] = scene_info

func _deserialize_game_state(data: Dictionary):
	gameState.day = data.get("day", 1)
	gameState.time = data.get("time", "08:00")
	gameState.weather = data.get("weather", "sunny")
	gameState.completedQuests = data.get("completedQuests", [])
	gameState.gameProgress = data.get("gameProgress", 0)
	gameState.currentScene = data.get("currentScene", "")
