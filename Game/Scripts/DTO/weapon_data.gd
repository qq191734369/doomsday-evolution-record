class_name WeaponData

# 武器类型枚举
enum WeaponType {
	MELEE,      # 近战武器
	RANGED,     # 远程武器
	MAGIC,      # 魔法武器
	TOOL        # 工具
}

# 武器稀有度枚举
enum WeaponRarity {
	COMMON,     # 普通
	UNCOMMON,   # 优秀
	RARE,       # 稀有
	EPIC,       # 史诗
	LEGENDARY   # 传说
}

# 武器基类
class WeaponInfo:
	var id: String = ""
	var name: String = ""
	var type: WeaponType = WeaponType.MELEE
	var rarity: WeaponRarity = WeaponRarity.COMMON
	var damage: int = 10
	var attack_speed: float = 2.0
	var durability: int = 100
	var max_durability: int = 100
	var range: float = 1.0
	var weight: float = 1.0
	var description: String = ""
	var effects: Array[Dictionary] = []
	var sprite_path: String = ""
	var animation_path: String = ""

	# 构造函数
	func _init(data: Dictionary = {}) -> void:
		id = data.get("id", id)
		name = data.get("name", name)
		type = data.get("type", type)
		rarity = data.get("rarity", rarity)
		damage = data.get("damage", damage)
		attack_speed = data.get("attack_speed", attack_speed)
		durability = data.get("durability", durability)
		max_durability = data.get("max_durability", max_durability)
		range = data.get("range", range)
		weight = data.get("weight", weight)
		description = data.get("description", description)
		effects = data.get("effects", effects)
		sprite_path = data.get("sprite_path", sprite_path)
		animation_path = data.get("animation_path", animation_path)

	# 检查武器是否可用
	func is_usable() -> bool:
		return durability > 0

	# 使用武器（减少耐久度）
	func use() -> bool:
		if not is_usable():
			return false
		durability -= 1
		return true

	# 修复武器
	func repair(amount: int = -1) -> void:
		if amount == -1:
			durability = max_durability
		else:
			durability = min(durability + amount, max_durability)

	# 获取武器效果
	func get_effects() -> Array[Dictionary]:
		return effects

# 近战武器类
class MeleeWeaponInfo extends WeaponInfo:
	var swing_range: float = 1.5
	var swing_angle: float = 90.0
	var blunt_damage: int = 0
	var slash_damage: int = 0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = WeaponType.MELEE
		swing_range = data.get("swing_range", swing_range)
		swing_angle = data.get("swing_angle", swing_angle)
		blunt_damage = data.get("blunt_damage", blunt_damage)
		slash_damage = data.get("slash_damage", slash_damage)

# 远程武器类
class RangedWeaponInfo extends WeaponInfo:
	var projectile_speed: float = 500.0
	var projectile_range: float = 1000.0
	var ammo_type: String = ""
	var ammo_capacity: int = 10
	var current_ammo: int = 10

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = WeaponType.RANGED
		projectile_speed = data.get("projectile_speed", projectile_speed)
		projectile_range = data.get("projectile_range", projectile_range)
		ammo_type = data.get("ammo_type", ammo_type)
		ammo_capacity = data.get("ammo_capacity", ammo_capacity)
		current_ammo = data.get("current_ammo", current_ammo)

	# 检查是否有弹药
	func has_ammo() -> bool:
		return current_ammo > 0

	# 装弹
	func reload(amount: int = -1) -> void:
		if amount == -1:
			current_ammo = ammo_capacity
		else:
			current_ammo = min(current_ammo + amount, ammo_capacity)

# 魔法武器类
class MagicWeaponInfo extends WeaponInfo:
	var mana_cost: int = 10
	var spell_effect: String = ""
	var cast_time: float = 0.5
	var cooldown: float = 1.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = WeaponType.MAGIC
		mana_cost = data.get("mana_cost", mana_cost)
		spell_effect = data.get("spell_effect", spell_effect)
		cast_time = data.get("cast_time", cast_time)
		cooldown = data.get("cooldown", cooldown)

# 工具类
class ToolInfo extends WeaponInfo:
	var tool_effect: String = ""
	var work_speed: float = 1.0
	var harvest_rate: float = 1.0

	func _init(data: Dictionary = {}) -> void:
		super(data)
		type = WeaponType.TOOL
		tool_effect = data.get("tool_effect", tool_effect)
		work_speed = data.get("work_speed", work_speed)
		harvest_rate = data.get("harvest_rate", harvest_rate)

# 武器管理器
class WeaponManager:
	static var singleton: WeaponManager

	var weapons: Dictionary[String, WeaponInfo] = {}

	static func get_instance() -> WeaponManager:
		if not WeaponManager.singleton:
			WeaponManager.singleton = WeaponManager.new()
		return WeaponManager.singleton

	# 添加武器
	func add_weapon(weapon_id: String, weapon: WeaponInfo) -> void:
		weapons[weapon_id] = weapon

	# 获取武器
	func get_weapon(weapon_id: String) -> WeaponInfo:
		return weapons.get(weapon_id, null)

	# 移除武器
	func remove_weapon(weapon_id: String) -> void:
		if weapon_id in weapons:
			weapons.erase(weapon_id)

	# 获取所有武器
	func get_all_weapons() -> Dictionary:
		return weapons

	# 根据类型获取武器
	func get_weapons_by_type(weapon_type: WeaponType) -> Array[WeaponInfo]:
		var result = []
		for weapon in weapons.values():
			if weapon.type == weapon_type:
				result.append(weapon)
		return result

	# 根据稀有度获取武器
	func get_weapons_by_rarity(weapon_rarity: WeaponRarity) -> Array[WeaponInfo]:
		var result = []
		for weapon in weapons.values():
			if weapon.rarity == weapon_rarity:
				result.append(weapon)
		return result
