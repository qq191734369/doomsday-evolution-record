class_name GameData

# 单例实例
static var singleton: GameData

class CharacterInfo:
	# 基础属性
	var base_attributes = {
		"max_health": 100,
		"attack_damage": 50,
		"speed": 200,
		"max_mana": 100,
		"strength": 10,      # 力量
		"intelligence": 10, # 智力
		"agility": 10,       # 敏捷
		"vitality": 10,      # 体质
		"spirit": 10         # 精神
	}
	# 战斗属性（受装备影响）
	var battle_attributes = {
		"defense": 0,           # 防御力
		"magic_resist": 0,      # 魔法防御
		"evasion": 0.0,         # 闪避率
		"crit_rate": 0.0,       # 暴击率
		"crit_damage": 0.0      # 爆伤
	}
	const MAX_ATTRIBUTE_VALUE = 9999

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
	var modifiers: Array[SkillData.Modifier] = []
	var currentState: String = "Idle"
	var	inParty: bool = false
	var	dialogueId: String
	var follow_distance = 50.0 # 跟随间距
	var stop_distance = 10.0
	var player_max_distance =  200.0  # 与玩家最大距离s
	var attack_range = 50.0 # 攻击范围
	var enemy_detection_range = 150.0 # 检测一定范围内的敌人
	var scene: String # 当前所在场景
	var talent_skill_id: String = ""       # 天赋技能ID
	var talent_level: int = 1               # 天赋等级（1-6）
	var passive_skill_ids: Dictionary = {}      # 被动技能字典 {skill_id: level}
	var active_skill_ids: Dictionary = {}       # 主动技能字典 {skill_id: level}
	var free_points: int = 0               # 自由属性点
	var free_points_per_level: int = 5      # 每级自由属性点成长值

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		base_attributes["max_health"] = data.get("maxHealth", 200)
		currentHealth = data.get("currentHealth", 200)
		base_attributes["max_mana"] = data.get("maxMana", 100)
		currentMana = data.get("currentMana", 100)
		base_attributes["attack_damage"] = data.get("attackDamage", 20)
		base_attributes["speed"] = data.get("speed", 200)
		base_attributes["strength"] = data.get("strength", 10)
		base_attributes["intelligence"] = data.get("intelligence", 10)
		base_attributes["agility"] = data.get("agility", 10)
		base_attributes["vitality"] = data.get("vitality", 10)
		base_attributes["spirit"] = data.get("spirit", 10)
		position = data.get("position", Vector2.ZERO)
		name = data.get("name", "Player")
		scene = data.get("scene", "")
		dialogueId = data.get("dialogueId", "")
		position = data.get("position", position)
		var equip_data = data.get("equipment")
		equipment = Equipment.new(equip_data if equip_data != null else {})
		skills = data.get("skills", [])
		var raw_modifiers = data.get("modifiers", [])
		if raw_modifiers is Array:
			for m in raw_modifiers:
				if m is SkillData.Modifier:
					modifiers.append(m)
				elif m is Dictionary:
					modifiers.append(SkillData.Modifier.new(m))
		battle_attributes["defense"] = data.get("defense", 0)
		battle_attributes["magic_resist"] = data.get("magic_resist", 0)
		battle_attributes["evasion"] = data.get("evasion", 0.0)
		battle_attributes["crit_rate"] = data.get("crit_rate", 0.0)
		battle_attributes["crit_damage"] = data.get("crit_damage", 0.0)
		bag = BagData.BagInfo.new(data.get("bag", {}))
		sync_equipment_modifiers()
		talent_skill_id = data.get("talent_skill_id", "")
		talent_level = data.get("talent_level", 1)
		passive_skill_ids = _parse_skill_dict(data.get("passive_skill_ids", {}))
		active_skill_ids = _parse_skill_dict(data.get("active_skill_ids", {}))
		free_points = data.get("free_points", 0)
		free_points_per_level = data.get("free_points_per_level", LevelData.DEFAULT_FREE_POINTS_PER_LEVEL)

	# 装备变化时的回调，子类可重写
	func on_equipment_changed():
		sync_equipment_modifiers()

	# 使用消耗品时的回调，子类可重写
	func on_consume_item(item_data: ItemData.ItemInfo):
		pass

	# 添加修饰符
	func add_modifier(modifier: SkillData.Modifier):
		modifiers.append(modifier)

	# 批量添加修饰符
	func add_modifiers(new_modifiers: Array[SkillData.Modifier]):
		modifiers.append_array(new_modifiers)

	# 移除指定来源的修饰符
	func remove_modifiers_by_source(source: SkillData.ModifierSource, source_id: String = ""):
		modifiers = modifiers.filter(func(m): return not (m.source == source and (source_id == "" or m.source_id == source_id)))

	# 同步装备修饰符
	func sync_equipment_modifiers():
		remove_modifiers_by_source(SkillData.ModifierSource.EQUIPMENT)
		remove_modifiers_by_source(SkillData.ModifierSource.WEAPON)
		if equipment:
			var all_equipment = [
				equipment.weapon,
				equipment.helmet,
				equipment.pauldrons,
				equipment.chestplate,
				equipment.greaves,
				equipment.belt,
				equipment.necklace,
				equipment.ring,
				equipment.ring2
			]
			for equip in all_equipment:
				if equip and equip.has_method("generate_modifiers"):
					add_modifiers(equip.generate_modifiers())

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
		# 检查最大值限制
		if attribute_name in ["strength", "intelligence", "agility", "vitality", "spirit"]:
			base_value = mini(base_value, MAX_ATTRIBUTE_VALUE)
		return base_value

	# 获取战斗属性值
	func get_battle_attribute(attribute_name: String) -> float:
		var value = battle_attributes.get(attribute_name, 0)
		for modifier in modifiers:
			if modifier.attribute == attribute_name:
				if modifier.type == SkillData.ModifierType.PERCENTAGE:
					value *= (1 + modifier.value)
				elif modifier.type == SkillData.ModifierType.FLAT:
					value += modifier.value
		return value

	# 便捷的属性获取方法
	func get_max_health() -> int:
		return int(get_attribute("max_health"))

	func get_attack_damage() -> int:
		return int(get_attribute("attack_damage"))

	func get_speed() -> float:
		return get_attribute("speed")

	func get_max_mana() -> int:
		return int(get_attribute("max_mana"))

	func get_strength() -> int:
		return int(get_attribute("strength"))

	func get_intelligence() -> int:
		return int(get_attribute("intelligence"))

	func get_agility() -> int:
		return int(get_attribute("agility"))

	func get_vitality() -> int:
		return int(get_attribute("vitality"))

	func get_spirit() -> int:
		return int(get_attribute("spirit"))

	func get_defense() -> float:
		return get_battle_attribute("defense")

	func get_magic_resist() -> float:
		return get_battle_attribute("magic_resist")

	func get_evasion() -> float:
		return get_battle_attribute("evasion")

	func get_crit_rate() -> float:
		return get_battle_attribute("crit_rate")

	func get_crit_damage() -> float:
		return get_battle_attribute("crit_damage")

	func equip(slot: String, item: ItemData.ItemInfo) -> ItemData.ItemInfo:
		if not equipment:
			return null
		var old_item: ItemData.ItemInfo = null
		match slot:
			"weapon":
				old_item = equipment.weapon
				equipment.weapon = item as WeaponData.WeaponInfo
			"helmet":
				old_item = equipment.helmet
				equipment.helmet = item as EquipmentData.HelmetInfo
			"pauldrons":
				old_item = equipment.pauldrons
				equipment.pauldrons = item as EquipmentData.PauldronsInfo
			"chestplate":
				old_item = equipment.chestplate
				equipment.chestplate = item as EquipmentData.ChestplateInfo
			"greaves":
				old_item = equipment.greaves
				equipment.greaves = item as EquipmentData.GreavesInfo
			"belt":
				old_item = equipment.belt
				equipment.belt = item as EquipmentData.BeltInfo
			"necklace":
				old_item = equipment.necklace
				equipment.necklace = item as EquipmentData.NecklaceInfo
			"ring1":
				old_item = equipment.ring
				equipment.ring = item as EquipmentData.RingInfo
			"ring2":
				old_item = equipment.ring2
				equipment.ring2 = item as EquipmentData.RingInfo
		on_equipment_changed()
		return old_item

	func get_talent_skill() -> SkillData.TalentSkillInfo:
		if talent_skill_id.is_empty():
			return null
		return SkillManager.get_talent_skill(talent_skill_id)

	func can_upgrade_talent() -> bool:
		var talent = get_talent_skill()
		if not talent:
			return false
		return talent_level < talent.max_level and talent.talent_type == SkillData.TalentType.PASSIVE

	func can_equip_passive_skill() -> bool:
		return passive_skill_ids.size() < 3

	func can_equip_active_skill() -> bool:
		return active_skill_ids.size() < 3

	func equip_talent_skill(talent_id: String) -> bool:
		if talent_id.is_empty() or not SkillManager.has_talent_skill(talent_id):
			return false
		talent_skill_id = talent_id
		talent_level = 1
		return true

	func equip_passive_skill(skill_id: String, level: int = 1) -> bool:
		if not can_equip_passive_skill() or not SkillManager.has_passive_skill(skill_id):
			return false
		passive_skill_ids[skill_id] = level
		return true

	func equip_active_skill(skill_id: String, level: int = 1) -> bool:
		if not can_equip_active_skill() or not SkillManager.has_active_skill(skill_id):
			return false
		active_skill_ids[skill_id] = level
		return true

	func get_passive_skill_level(skill_id: String) -> int:
		return passive_skill_ids.get(skill_id, 0)

	func get_active_skill_level(skill_id: String) -> int:
		return active_skill_ids.get(skill_id, 0)

	func upgrade_passive_skill(skill_id: String) -> bool:
		if not passive_skill_ids.has(skill_id):
			return false
		var skill = SkillManager.get_passive_skill(skill_id)
		if not skill or not skill.has("max_level"):
			return false
		var current_level = passive_skill_ids[skill_id]
		if current_level >= skill.max_level:
			return false
		passive_skill_ids[skill_id] = current_level + 1
		return true

	func upgrade_active_skill(skill_id: String) -> bool:
		if not active_skill_ids.has(skill_id):
			return false
		var skill = SkillManager.get_active_skill(skill_id)
		if not skill or not skill.has("max_level"):
			return false
		var current_level = active_skill_ids[skill_id]
		if current_level >= skill.max_level:
			return false
		active_skill_ids[skill_id] = current_level + 1
		return true

	func unequip_talent_skill() -> String:
		var old_id = talent_skill_id
		talent_skill_id = ""
		talent_level = 1
		return old_id

	func unequip_passive_skill(skill_id: String) -> bool:
		if passive_skill_ids.has(skill_id):
			passive_skill_ids.erase(skill_id)
			return true
		return false

	func unequip_active_skill(skill_id: String) -> bool:
		if active_skill_ids.has(skill_id):
			active_skill_ids.erase(skill_id)
			return true
		return false

	static func _parse_skill_dict(data) -> Dictionary:
		if data is Dictionary:
			return data
		if data is Array:
			var result = {}
			for skill_id in data:
				if skill_id is String:
					result[skill_id] = 1
			return result
		return {}

class Equipment:
	var weapon: WeaponData.WeaponInfo
	var helmet: EquipmentData.HelmetInfo
	var pauldrons: EquipmentData.PauldronsInfo
	var chestplate: EquipmentData.ChestplateInfo
	var greaves: EquipmentData.GreavesInfo
	var belt: EquipmentData.BeltInfo
	var necklace: EquipmentData.NecklaceInfo
	var ring: EquipmentData.RingInfo
	var ring2: EquipmentData.RingInfo

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

		var helmetData = data.get("helmet")
		if helmetData:
			helmet = EquipmentData.HelmetInfo.new(helmetData)

		var pauldronsData = data.get("pauldrons")
		if pauldronsData:
			pauldrons = EquipmentData.PauldronsInfo.new(pauldronsData)

		var chestplateData = data.get("chestplate")
		if chestplateData:
			chestplate = EquipmentData.ChestplateInfo.new(chestplateData)

		var greavesData = data.get("greaves")
		if greavesData:
			greaves = EquipmentData.GreavesInfo.new(greavesData)

		var beltData = data.get("belt")
		if beltData:
			belt = EquipmentData.BeltInfo.new(beltData)

		var necklaceData = data.get("necklace")
		if necklaceData:
			necklace = EquipmentData.NecklaceInfo.new(necklaceData)

		var ringData = data.get("ring")
		if ringData:
			ring = EquipmentData.RingInfo.new(ringData)

		var ring2Data = data.get("ring2")
		if ring2Data:
			ring2 = EquipmentData.RingInfo.new(ring2Data)

class EnemyInfo:
	var maxHealth: int = 80
	var currentHealth: int = 80
	var attackDamage: int = 20
	var speed: int = 150
	var position: Vector2 = Vector2.ZERO
	var type: String = "Zombie"
	var scene: String = ""
	var experience: int = 50

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
	"id": "Player",
	"name": "Player",
	"position": Vector2(689.0, 373.0),
	"attackDamage": 50,
	"talent_skill_id": "talent_strength",
	"talent_level": 1,
	"passive_skill_ids": {"passive_vitality": 1},
	"active_skill_ids": {"basic_attack": 1, "fire_ball": 1, "heal": 1},
	"bag": {
		"consume": [{
			"id": "water",
			"name": "water",
			"type": 1,
			"stackable": true,
			"quantity": 1,
			"count": 9
		}],
		"equipment": [
			{
				"id": "sword_001",
				"name": "铁剑",
				"rarity": 0,
				"description": "一把普通的铁剑",
				"value": 100,
				"weapon_type": 1,
				"damage": 25,
				"attack_speed": 1.5,
				"range": 50
			},
			{
				"id": "helmet_001",
				"name": "铁头盔",
				"rarity": 0,
				"description": "基础的铁头盔",
				"value": 80,
				"armor_type": 1,
				"defense": 5,
				"magic_resist": 2
			},
			{
				"id": "chestplate_001",
				"name": "铁胸甲",
				"rarity": 0,
				"description": "基础的铁胸甲",
				"value": 150,
				"armor_type": 3,
				"defense": 10,
				"magic_resist": 3
			},
			{
				"id": "greaves_001",
				"name": "铁护腿",
				"rarity": 0,
				"description": "基础的铁护腿",
				"value": 100,
				"armor_type": 4,
				"defense": 6,
				"magic_resist": 2
			},
			{
				"id": "ring_001",
				"name": "力量戒指",
				"rarity": 1,
				"description": "增加攻击力的戒指",
				"value": 200,
				"accessory_type": 2,
				"damage_bonus": 0.1
			},
			{
				"id": "necklace_001",
				"name": "生命项链",
				"rarity": 1,
				"description": "增加生命值的项链",
				"value": 250,
				"accessory_type": 1,
				"health_bonus": 30
			},
			{
				"id": "belt_001",
				"name": "皮腰带",
				"rarity": 0,
				"description": "普通的皮腰带",
				"value": 50,
				"armor_type": 5,
				"defense": 2
			}
		]
	},
	"equipment": {
		"weapon": {
			"id": "gun",
			"weapon_type": 2,
			"name": "Gun",
			"damage": 50,
			"projectile_range": 300
		}
	}
})

# npc信息
var npcDictionary: Dictionary[String, CharacterInfo] = {
	"LiMei": CharacterInfo.new({
		"id": "LiMei",
		"name": "LiMei",
		"speed": 200,
		"dialogueId": "limei_join_start",
		"scene": "main",
		"position": Vector2(689.0, 373.0),
		"maxHealth": 500,
		"attackDamage": 30,
		"talent_skill_id": "talent_vitality",
		"talent_level": 1,
		"passive_skill_ids": {"passive_strength": 2},
		"active_skill_ids": {"power_strike": 1, "thunder_strike": 1}
	}),
	"ZhaoXinEr": CharacterInfo.new({
		"id": "ZhaoXinEr",
		"name": "ZhaoXinEr",
		"speed": 200,
		"dialogueId": "zhaoxiner_join_start",
		"scene": "main",
		"position": Vector2(720.0, 373.0),
		"equipment": {
			"weapon": {
				"id": "gun",
				"weapon_type": 2,
				"name": "Gun",
				"damage": 50,
				"projectile_range": 300
			}
		},
		"talent_skill_id": "talent_fire_blade",
		"talent_level": 2,
		"passive_skill_ids": {"passive_crit": 3},
		"active_skill_ids": {"quick_shot": 1, "fire_ball": 2}
	}),
	"ZhuangFangYi": CharacterInfo.new({
		"id": "ZhuangFangYi",
		"name": "ZhuangFangYi",
		"speed": 200,
		"dialogueId": "zhuangfangyi_join_start",
		"scene": "main",
		"position": Vector2(720.0, 300.0),
		"talent_skill_id": "talent_ice_shield",
		"talent_level": 1,
		"passive_skill_ids": {"passive_vitality": 2, "passive_speed": 1},
		"active_skill_ids": {"heal": 1, "basic_attack": 1}
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
		"talent_skill_id": player.talent_skill_id,
		"talent_level": player.talent_level,
		"passive_skill_ids": player.passive_skill_ids,
		"active_skill_ids": player.active_skill_ids,
		"free_points": player.free_points,
		"free_points_per_level": player.free_points_per_level,
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
			"level": npc.level,
			"experience": npc.experience,
			"scene": npc.scene,
			"inParty": npc.inParty,
			"dialogueId": npc.dialogueId,
			"equipment": serialized_equipment,
			"skills": npc.skills,
			"talent_skill_id": npc.talent_skill_id,
			"talent_level": npc.talent_level,
			"passive_skill_ids": npc.passive_skill_ids,
			"active_skill_ids": npc.active_skill_ids,
			"free_points": npc.free_points,
			"free_points_per_level": npc.free_points_per_level,
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
			"scene": enemy.scene,
			"experience": enemy.experience
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
	player.talent_skill_id = data.get("talent_skill_id", "")
	player.talent_level = data.get("talent_level", 1)
	player.passive_skill_ids = data.get("passive_skill_ids", [])
	player.active_skill_ids = data.get("active_skill_ids", [])
	player.free_points = data.get("free_points", 0)
	player.free_points_per_level = data.get("free_points_per_level", LevelData.DEFAULT_FREE_POINTS_PER_LEVEL)
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
		npc_info.level = npc_data.get("level", 1)
		npc_info.experience = npc_data.get("experience", 0)
		npc_info.scene = npc_data.get("scene", "")
		npc_info.inParty = npc_data.get("inParty", false)
		npc_info.dialogueId = npc_data.get("dialogueId", "")

		# 反序列化装备
		var equipment_data = npc_data.get("equipment", {})
		npc_info.equipment = Equipment.new(equipment_data)

		npc_info.skills = npc_data.get("skills", [])
		npc_info.talent_skill_id = npc_data.get("talent_skill_id", "")
		npc_info.talent_level = npc_data.get("talent_level", 1)
		npc_info.passive_skill_ids = npc_data.get("passive_skill_ids", [])
		npc_info.active_skill_ids = npc_data.get("active_skill_ids", [])
		npc_info.free_points = npc_data.get("free_points", 0)
		npc_info.free_points_per_level = npc_data.get("free_points_per_level", LevelData.DEFAULT_FREE_POINTS_PER_LEVEL)
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
		enemy_info.experience = enemy_data.get("experience", 50)
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
