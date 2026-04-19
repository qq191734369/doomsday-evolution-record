class_name EquipmentData

enum ArmorType {
	NONE = 0,
	HELMET,      # 头盔
	PAULDRONS,   # 护肩
	CHESTPLATE,  # 衣服
	GREAVES,     # 护腿
	BELT         # 腰带
}

enum AccessoryType {
	NONE = 0,
	NECKLACE,    # 项链
	RING         # 戒指
}

static func create_equipment(data: Dictionary):
	if data.is_empty():
		return null
	if data.has("accessory_type"):
		var accessory_type_val = data.get("accessory_type")
		match accessory_type_val as int:
			AccessoryType.NECKLACE:
				return NecklaceInfo.new(data)
			AccessoryType.RING:
				return RingInfo.new(data)
	if data.has("weapon_type"):
		var weapon_type_val = data.get("weapon_type")
		match weapon_type_val as int:
			WeaponData.WeaponType.MELEE:
				return WeaponData.MeleeWeaponInfo.new(data)
			WeaponData.WeaponType.RANGED:
				return WeaponData.RangedWeaponInfo.new(data)
			WeaponData.WeaponType.MAGIC:
				return WeaponData.MagicWeaponInfo.new(data)
			WeaponData.WeaponType.TOOL:
				return WeaponData.ToolInfo.new(data)
	if data.has("armor_type"):
		var armor_type_val = data.get("armor_type")
		match armor_type_val as int:
			ArmorType.HELMET:
				return HelmetInfo.new(data)
			ArmorType.PAULDRONS:
				return PauldronsInfo.new(data)
			ArmorType.CHESTPLATE:
				return ChestplateInfo.new(data)
			ArmorType.GREAVES:
				return GreavesInfo.new(data)
			ArmorType.BELT:
				return BeltInfo.new(data)
	return EquipmentInfo.new(data)

class EquipmentInfo extends ItemData.ItemInfo:
	var is_equipment: bool
	var armor_type: ArmorType
	var accessory_type: AccessoryType

	func _init(data: Dictionary):
		super(data)
		is_equipment = true

class HelmetInfo extends EquipmentInfo:
	var defense: int = 5
	var magic_resist: int = 2
	var health_bonus: int = 0

	func _init(data: Dictionary = {}):
		super(data)
		armor_type = ArmorType.HELMET
		defense = data.get("defense", defense)
		magic_resist = data.get("magic_resist", magic_resist)
		health_bonus = data.get("health_bonus", health_bonus)

class PauldronsInfo extends EquipmentInfo:
	var defense: int = 3
	var magic_resist: int = 1
	var move_speed_bonus: float = 0.0

	func _init(data: Dictionary = {}):
		super(data)
		armor_type = ArmorType.PAULDRONS
		defense = data.get("defense", defense)
		magic_resist = data.get("magic_resist", magic_resist)
		move_speed_bonus = data.get("move_speed_bonus", move_speed_bonus)

class ChestplateInfo extends EquipmentInfo:
	var defense: int = 10
	var magic_resist: int = 3
	var health_bonus: int = 20

	func _init(data: Dictionary = {}):
		super(data)
		armor_type = ArmorType.CHESTPLATE
		defense = data.get("defense", defense)
		magic_resist = data.get("magic_resist", magic_resist)
		health_bonus = data.get("health_bonus", health_bonus)

class GreavesInfo extends EquipmentInfo:
	var defense: int = 6
	var magic_resist: int = 2
	var move_speed_bonus: float = 0.05

	func _init(data: Dictionary = {}):
		super(data)
		armor_type = ArmorType.GREAVES
		defense = data.get("defense", defense)
		magic_resist = data.get("magic_resist", magic_resist)
		move_speed_bonus = data.get("move_speed_bonus", move_speed_bonus)

class BeltInfo extends EquipmentInfo:
	var defense: int = 2
	var magic_resist: int = 1
	var health_bonus: int = 10
	var mana_bonus: int = 5

	func _init(data: Dictionary = {}):
		super(data)
		armor_type = ArmorType.BELT
		defense = data.get("defense", defense)
		magic_resist = data.get("magic_resist", magic_resist)
		health_bonus = data.get("health_bonus", health_bonus)
		mana_bonus = data.get("mana_bonus", mana_bonus)

class NecklaceInfo extends EquipmentInfo:
	var magic_resist: int = 5
	var health_bonus: int = 15
	var mana_bonus: int = 10
	var luck_bonus: float = 0.0

	func _init(data: Dictionary = {}):
		super(data)
		accessory_type = AccessoryType.NECKLACE
		magic_resist = data.get("magic_resist", magic_resist)
		health_bonus = data.get("health_bonus", health_bonus)
		mana_bonus = data.get("mana_bonus", mana_bonus)
		luck_bonus = data.get("luck_bonus", luck_bonus)

class RingInfo extends EquipmentInfo:
	var damage_bonus: float = 0.0
	var attack_speed_bonus: float = 0.0
	var health_bonus: int = 10
	var mana_bonus: int = 10
	var crit_rate_bonus: float = 0.0

	func _init(data: Dictionary = {}):
		super(data)
		accessory_type = AccessoryType.RING
		damage_bonus = data.get("damage_bonus", damage_bonus)
		attack_speed_bonus = data.get("attack_speed_bonus", attack_speed_bonus)
		health_bonus = data.get("health_bonus", health_bonus)
		mana_bonus = data.get("mana_bonus", mana_bonus)
		crit_rate_bonus = data.get("crit_rate_bonus", crit_rate_bonus)
