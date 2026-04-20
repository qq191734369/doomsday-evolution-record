extends Panel

class_name CharacterDetailUI

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(d: GameData.CharacterInfo):
	var data = d
	texture_rect_character.texture = load("res://Assets/Animation/Characters/{name}/{name}_full.png".format({ "name": data.name }))
	label_character_name.text = data.name
	update_equipment_slots(data.equipment)

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
