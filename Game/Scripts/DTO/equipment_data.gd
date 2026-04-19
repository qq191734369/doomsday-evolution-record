class_name EquipmentData

enum ArmorType {
	HELMET,      # 头盔
	PAULDRONS,   # 护肩
	CHESTPLATE,  # 衣服
	GREAVES,     # 护腿
	BELT         # 腰带
}

enum AccessoryType {
	NECKLACE,    # 项链
	RING         # 戒指
}

class EquipmentInfo extends ItemData.ItemInfo:
	var is_equipment: bool
	var armor_type: ArmorType
	var accessory_type: AccessoryType

	func _init(data: Dictionary):
		super(data)
		is_equipment = true
		armor_type = data.get("armor_type", ArmorType.HELMET)
		accessory_type = data.get("accessory_type", AccessoryType.NECKLACE)

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
