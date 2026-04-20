extends Panel

class_name CharacterDetailUI

signal equipment_changed(slot_name: String, item_data: ItemData.ItemInfo, old_item: ItemData.ItemInfo, from_bag_index: int)

# 装备栏
@onready var texture_rect_character: TextureRect = $TextureRect_Character
@onready var label_character_name: Label = $TextureRect_Name/Label_CharacterName
@onready var equipment_slot_weapon: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Weapon
@onready var equipment_slot_head: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Head
@onready var equipment_slot_arm: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Arm
@onready var equipment_slot_body: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Body
@onready var equipment_slot_leg: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Leg
@onready var equipment_slot_belt: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Belt
@onready var equipment_slot_necklace: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Necklace
@onready var equipment_slot_ring_1: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Ring1
@onready var equipment_slot_ring_2: EquipmentSlotNode = $NinePatchRect_EquipmentContainer/EquipmentSlot_Ring2


# 数据栏
# 攻击力
@onready var key_value_atk: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_ATK
# 防御
@onready var key_value_defense: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_Defense
# 速度
@onready var key_value_speed: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_Speed
# 闪避
@onready var key_value_eva: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_EVA
# HP
@onready var key_value_health: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_Health
# MP
@onready var key_value_mana: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_Mana
# 暴击率
@onready var key_value_crit: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_CRIT
# 暴击伤害
@onready var key_value_critd: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_CRITD
# 魔法防御
@onready var key_value_mr: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_MR
# 力量
@onready var key_value_str: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_STR
# 智力
@onready var key_value_int: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_INT
# 敏捷
@onready var key_value_agi: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_AGI
# 体质
@onready var key_value_vit: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_VIT
# 精神
@onready var key_value_spi: KeyValueNode = $NinePatchRect_DataContainer/KeyValue_SPI


var _current_character: GameData.CharacterInfo = null
var _current_character_node: BaseCharacter = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_equipment_slot_signals()


func _connect_equipment_slot_signals():
	var slots = [
		equipment_slot_weapon,
		equipment_slot_head,
		equipment_slot_arm,
		equipment_slot_body,
		equipment_slot_leg,
		equipment_slot_belt,
		equipment_slot_necklace,
		equipment_slot_ring_1,
		equipment_slot_ring_2
	]
	for slot in slots:
		if slot and slot.has_signal("equipment_dropped"):
			if not slot.equipment_dropped.is_connected(_on_equipment_slot_dropped):
				slot.equipment_dropped.connect(_on_equipment_slot_dropped)


func _on_equipment_slot_dropped(slot_type: EquipmentSlotNode.EquipmentSlotType, item_data: ItemData.ItemInfo, from_bag_index: int):
	print("[CharacterDetailUI] _on_equipment_slot_dropped: slot_type=", slot_type, " item=", item_data.name if item_data else "null", " from_bag_index=", from_bag_index)
	if not _current_character:
		print("[CharacterDetailUI] _on_equipment_slot_dropped: _current_character is null")
		return
	var slot_name = _get_slot_name_from_type(slot_type)
	var slot_node = _get_slot_node_from_type(slot_type)
	print("[CharacterDetailUI] _on_equipment_slot_dropped: slot_name=", slot_name, " slot_node=", slot_node)
	if not slot_name or not slot_node:
		return
	var old_item = _current_character.equip(slot_name, item_data)
	print("[CharacterDetailUI] _on_equipment_slot_dropped: old_item=", old_item.name if old_item else "null")
	slot_node.init(item_data)
	equipment_changed.emit(slot_name, item_data, old_item, from_bag_index)
	update_data_panel(_current_character)
	if item_data is WeaponData.WeaponInfo:
		_refresh_character_weapon()


func _get_slot_name_from_type(slot_type: EquipmentSlotNode.EquipmentSlotType) -> String:
	match slot_type:
		EquipmentSlotNode.EquipmentSlotType.WEAPON:
			return "weapon"
		EquipmentSlotNode.EquipmentSlotType.HELMET:
			return "helmet"
		EquipmentSlotNode.EquipmentSlotType.PAULDRONS:
			return "pauldrons"
		EquipmentSlotNode.EquipmentSlotType.CHESTPLATE:
			return "chestplate"
		EquipmentSlotNode.EquipmentSlotType.GREAVES:
			return "greaves"
		EquipmentSlotNode.EquipmentSlotType.BELT:
			return "belt"
		EquipmentSlotNode.EquipmentSlotType.NECKLACE:
			return "necklace"
		EquipmentSlotNode.EquipmentSlotType.RING1:
			return "ring1"
		EquipmentSlotNode.EquipmentSlotType.RING2:
			return "ring2"
	return ""


func _get_slot_node_from_type(slot_type: EquipmentSlotNode.EquipmentSlotType) -> EquipmentSlotNode:
	match slot_type:
		EquipmentSlotNode.EquipmentSlotType.WEAPON:
			return equipment_slot_weapon
		EquipmentSlotNode.EquipmentSlotType.HELMET:
			return equipment_slot_head
		EquipmentSlotNode.EquipmentSlotType.PAULDRONS:
			return equipment_slot_arm
		EquipmentSlotNode.EquipmentSlotType.CHESTPLATE:
			return equipment_slot_body
		EquipmentSlotNode.EquipmentSlotType.GREAVES:
			return equipment_slot_leg
		EquipmentSlotNode.EquipmentSlotType.BELT:
			return equipment_slot_belt
		EquipmentSlotNode.EquipmentSlotType.NECKLACE:
			return equipment_slot_necklace
		EquipmentSlotNode.EquipmentSlotType.RING1:
			return equipment_slot_ring_1
		EquipmentSlotNode.EquipmentSlotType.RING2:
			return equipment_slot_ring_2
	return null


func _refresh_character_weapon():
	print("[CharacterDetailUI] _refresh_character_weapon: _current_character=", _current_character.name if _current_character else "null")
	_current_character_node.refresh_equipment()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(val: BaseCharacter):
	_current_character_node = val
	var d = val.data
	_current_character = d
	texture_rect_character.texture = load("res://Assets/Animation/Characters/{name}/{name}_full.png".format({ "name": d.name }))
	label_character_name.text = d.name
	update_equipment_slots(d.equipment)
	update_data_panel(d)

func update_data_panel(d: GameData.CharacterInfo):
	if key_value_health:
		key_value_health.value = "%d/%d" % [d.currentHealth, d.get_max_health()]
		key_value_health.max_value = d.get_max_health()
	if key_value_mana:
		key_value_mana.value = "%d/%d" % [d.currentMana, d.get_max_mana()]
		key_value_mana.max_value = d.get_max_mana()
	if key_value_atk:
		key_value_atk.value = str(d.get_attack_damage())
	if key_value_defense:
		key_value_defense.value = str(d.get_defense())
	if key_value_speed:
		key_value_speed.value = str(d.get_speed())
	if key_value_eva:
		key_value_eva.value = str(d.get_evasion())
	if key_value_crit:
		key_value_crit.value = str(d.get_crit_rate())
	if key_value_critd:
		key_value_critd.value = str(d.get_crit_damage())
	if key_value_mr:
		key_value_mr.value = str(d.get_magic_resist())
	if key_value_str:
		key_value_str.value = str(d.get_strength())
	if key_value_int:
		key_value_int.value = str(d.get_intelligence())
	if key_value_agi:
		key_value_agi.value = str(d.get_agility())
	if key_value_vit:
		key_value_vit.value = str(d.get_vitality())
	if key_value_spi:
		key_value_spi.value = str(d.get_spirit())

func update_equipment_slots(equip: GameData.Equipment):
	if not equip:
		equipment_slot_weapon.clear()
		equipment_slot_head.clear()
		equipment_slot_arm.clear()
		equipment_slot_body.clear()
		equipment_slot_leg.clear()
		equipment_slot_belt.clear()
		equipment_slot_necklace.clear()
		equipment_slot_ring_1.clear()
		equipment_slot_ring_2.clear()
		return
	equipment_slot_weapon.init(equip.weapon)
	equipment_slot_head.init(equip.helmet)
	equipment_slot_arm.init(equip.pauldrons)
	equipment_slot_body.init(equip.chestplate)
	equipment_slot_leg.init(equip.greaves)
	equipment_slot_belt.init(equip.belt)
	equipment_slot_necklace.init(equip.necklace)
	equipment_slot_ring_1.init(equip.ring)
	equipment_slot_ring_2.init(equip.ring2)
