class_name GameData

# 单例实例
static var singleton: GameData

class CharacterInfo:
	# 基础属性
	var base_attributes = {
		"max_health": 100,
		"attack_damage": 50,
		"speed": 200,
		"max_mana": 100
	}
	var id: String # 角色id，全局唯一
	var currentHealth: int = 100
	var currentMana: int = 100
	var position: Vector2 = Vector2.ZERO
	var name: String = ""
	var level: int = 1
	var experience: int = 0
	var bag: BagData.BagInfo
	var equipment: Equipment
	var skills: Array = []
	var modifiers: Array = []
	var currentState: String = "Idle"
	var	inParty: bool = false
	var	dialogueId: String
	var follow_distance = 50.0 # 跟随间距
	var stop_distance = 10.0
	var player_max_distance =  200.0  # 与玩家最大距离s
	var attack_range = 50.0 # 攻击范围
	var enemy_detection_range = 150.0 # 检测一定范围内的敌人
	var scene: String # 当前所在场景

	func _init(data: Dictionary) -> void:
		base_attributes["max_health"] = data.get("maxHealth", 200)
		currentHealth = data.get("currentHealth", 200)
		base_attributes["max_mana"] = data.get("maxMana", 100)
		currentMana = data.get("currentMana", 100)
		base_attributes["attack_damage"] = data.get("attackDamage", 20)
		base_attributes["speed"] = data.get("speed", 200)
		position = data.get("position", Vector2.ZERO)
		name = data.get("name", "Player")
		scene = data.get("scene", "")
		dialogueId = data.get("dialogueId", "")
		position = data.get("position", position)
		var equip_data = data.get("equipment")
		equipment = Equipment.new(equip_data if equip_data != null else {})
		skills = data.get("skills", [])
		modifiers = data.get("modifiers", [])
		# 初始化背包
		bag = BagData.BagInfo.new(data.get("bag", {}))
		
	# 添加修饰符
	func add_modifier(modifier: Dictionary):
		modifiers.append(modifier)

	# 移除修饰符
	func remove_modifier(modifier_id: String):
		modifiers = modifiers.filter(func(m): return m.id != modifier_id)

	# 获取属性值
	func get_attribute(attribute_name: String) -> float:
		var base_value = base_attributes.get(attribute_name, 0)
		
		# 应用修饰符（包括装备修饰符）
		for modifier in modifiers:
			if modifier.attribute == attribute_name:
				if modifier.type == SkillData.ModifierType.PERCENTAGE:
					base_value *= (1 + modifier.value)
				elif modifier.type == SkillData.ModifierType.FLAT:
					base_value += modifier.value
		
		return base_value

	# 便捷的属性获取方法
	func get_max_health() -> int:
		return int(get_attribute("max_health"))

	func get_attack_damage() -> int:
		return int(get_attribute("attack_damage"))

	func get_speed() -> float:
		return get_attribute("speed")

	func get_max_mana() -> int:
		return int(get_attribute("max_mana"))

class Equipment:
	var weapon: WeaponData.WeaponInfo
	
	func _init(data: Dictionary = {}) -> void:
		var weaponData = data.get("weapon")
		if weaponData:
			var type = weaponData.get("weapon_type")
			if type == WeaponData.WeaponType.MELEE:
				weapon = WeaponData.MeleeWeaponInfo.new(weaponData)
			elif type == WeaponData.WeaponType.RANGED:
				weapon = WeaponData.RangedWeaponInfo.new(weaponData)
			elif type == WeaponData.WeaponType.MAGIC:
				weapon = WeaponData.MagicWeaponInfo.new(weaponData)
			elif type == WeaponData.WeaponType.TOOL:
				weapon = WeaponData.ToolInfo.new(weaponData)

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
var player: CharacterInfo = CharacterInfo.new({
	"name": "Player",
	"position": Vector2(689.0, 373.0),
	"attackDamage": 50,
	"bag": {
		"consume": [{
			"id": "water",
			"name": "water",
			"type": 1,
			"stackable": true,
			"quantity": 1,
			"count": 9
		}]
	},
	"equipment": {
		"weapon": {
			"weapon_type": 1,
			"name": "Gun",
			"damage": 50,
			"range": 200.0
		}
	}
})

# npc信息
var npcDictionary: Dictionary[String, CharacterInfo] = {
	"LiMei": CharacterInfo.new({
		"name": "LiMei",
		"speed": 200,
		"dialogueId": "limei_join_start",
		"scene": "main",
		"position": Vector2(689.0, 373.0),
		"maxHealth": 500,
		"attackDamage": 30
	}),
	"ZhaoXinEr": CharacterInfo.new({
		"name": "ZhaoXinEr",
		"speed": 200,
		"dialogueId": "zhaoxiner_join_start",
		"scene": "main",
		"position": Vector2(720.0, 373.0),
		"equipment": {
			"weapon": {
				"weapon_type": 1,
				"name": "Gun",
				"damage": 50,
				"range": 200.0
			}
		}
	})
}

# 第一个为玩家
var partyList: Array[String] = []

func getNpcPartyMember():
	return partyList.filter(func(n): return n != "Player")

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
	#player = CharacterInfo.new({})
	#gameState = GameStateInfo.new()
	pass

func isInParty(name: String) -> bool:
	return partyList.has(name)

# 玩家数据管理
func update_player_data(data: Dictionary):
	if player:
		for key in data.keys():
			if player.has(key):
				player[key] = data[key]

func get_player_data() -> CharacterInfo:
	return player

# NPC数据管理
func add_npc_data(npc_id: String, data: Dictionary):
	var npc_info = CharacterInfo.new({})
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

func get_npc_data(npc_id: String) -> CharacterInfo:
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
	# 序列化背包
	var serialized_inventory = []
	if player.inventory:
		for slot in player.inventory.slots:
			if slot.item_id != "":
				serialized_inventory.append({
					"item_id": slot.item_id,
					"quantity": slot.quantity
				})

	# 序列化装备
	var serialized_equipment = {}
	if player.equipment and player.equipment.weapon:
		serialized_equipment["weapon"] = {
			"id": player.equipment.weapon.id,
			"name": player.equipment.weapon.name,
			"damage": player.equipment.weapon.damage,
			"range": player.equipment.weapon.range
		}

	var data = {
		"maxHealth": player.base_attributes["max_health"],
		"currentHealth": player.currentHealth,
		"maxMana": player.base_attributes["max_mana"],
		"currentMana": player.currentMana,
		"attackDamage": player.base_attributes["attack_damage"],
		"speed": player.base_attributes["speed"],
		"position": [player.position.x, player.position.y],
		"name": player.name,
		"level": player.level,
		"experience": player.experience,
		"equipment": serialized_equipment,
		"skills": player.skills,
		"modifiers": player.modifiers,
		"currentState": player.currentState
	}
	return data

func _serialize_npcs() -> Dictionary:
	var data = {}
	for npc_id in npcDictionary.keys():
		var npc = npcDictionary[npc_id]
		# 序列化装备
		var serialized_equipment = {}
		if npc.equipment and npc.equipment.weapon:
			serialized_equipment["weapon"] = {
				"id": npc.equipment.weapon.id,
				"name": npc.equipment.weapon.name,
				"damage": npc.equipment.weapon.damage,
				"range": npc.equipment.weapon.range
			}

		data[npc_id] = {
			"maxHealth": npc.base_attributes["max_health"],
			"currentHealth": npc.currentHealth,
			"maxMana": npc.base_attributes["max_mana"],
			"currentMana": npc.currentMana,
			"attackDamage": npc.base_attributes["attack_damage"],
			"speed": npc.base_attributes["speed"],
			"position": [npc.position.x, npc.position.y],
			"name": npc.name,
			"scene": npc.scene,
			"inParty": npc.inParty,
			"dialogueId": npc.dialogueId,
			"equipment": serialized_equipment,
			"skills": npc.skills,
			"modifiers": npc.modifiers
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
	player.base_attributes["max_health"] = data.get("maxHealth", 100)
	player.currentHealth = data.get("currentHealth", 100)
	player.base_attributes["max_mana"] = data.get("maxMana", 100)
	player.currentMana = data.get("currentMana", 100)
	player.base_attributes["attack_damage"] = data.get("attackDamage", 50)
	player.base_attributes["speed"] = data.get("speed", 200)
	if "position" in data and data["position"] is Array:
		player.position = Vector2(data["position"][0], data["position"][1])
	player.name = data.get("name", "Player")
	player.level = data.get("level", 1)
	player.experience = data.get("experience", 0)
	
	# 初始化背包
	player.bag = BagData.BagInfo.new()
	
	# 反序列化装备
	var equipment_data = data.get("equipment", {})
	player.equipment = Equipment.new(equipment_data)
	
	player.skills = data.get("skills", [])
	player.modifiers = data.get("modifiers", [])
	player.currentState = data.get("currentState", "Idle")

func _deserialize_npcs(data: Dictionary):
	npcDictionary.clear()
	for npc_id in data.keys():
		var npc_data = data[npc_id]
		var npc_info = CharacterInfo.new({})
		npc_info.base_attributes["max_health"] = npc_data.get("maxHealth", 100)
		npc_info.currentHealth = npc_data.get("currentHealth", 100)
		npc_info.base_attributes["max_mana"] = npc_data.get("maxMana", 100)
		npc_info.currentMana = npc_data.get("currentMana", 100)
		npc_info.base_attributes["attack_damage"] = npc_data.get("attackDamage", 30)
		npc_info.base_attributes["speed"] = npc_data.get("speed", 180)
		if "position" in npc_data and npc_data["position"] is Array:
			npc_info.position = Vector2(npc_data["position"][0], npc_data["position"][1])
		npc_info.name = npc_data.get("name", "NPC")
		npc_info.scene = npc_data.get("scene", "")
		npc_info.inParty = npc_data.get("inParty", false)
		npc_info.dialogueId = npc_data.get("dialogueId", "")
		
		# 反序列化装备
		var equipment_data = npc_data.get("equipment", {})
		npc_info.equipment = Equipment.new(equipment_data)
		
		npc_info.skills = npc_data.get("skills", [])
		npc_info.modifiers = npc_data.get("modifiers", [])
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
