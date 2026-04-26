extends TextureRect

class_name EquipmentSlotNode

enum EquipmentSlotType {
	WEAPON,
	HELMET,
	PAULDRONS,
	CHESTPLATE,
	GREAVES,
	BELT,
	NECKLACE,
	RING1,
	RING2
}

signal equipment_dropped(slot_type: EquipmentSlotType, item_data: ItemData.ItemInfo, from_bag_index: int)

@onready var texture_rect_item_view: TextureRect = $MarginContainer/TextureRect_ItemView
@onready var ghost: TextureRect = $Ghost
@onready var label_fallback: Label = $Label_Fallback
@onready var label_description: Label = $Label_Description

@export var item_database: ItemDatabase
@export var des: String = "":
	set(val):
		if label_description:
			label_description.text = val
		else:
			_pending_des = val

@export var slot_type: EquipmentSlotType = EquipmentSlotType.WEAPON


var _pending_des: String = ""
var _drag_data: Dictionary = {}


var slot_index: int = -1
var _data: ItemData.ItemInfo
var data: ItemData.ItemInfo:
	set(val):
		if not item_database:
			return
		_data = val
		if not val:
			texture_rect_item_view.texture = null
			label_fallback.text = ""
			return
		var texture = item_database.get_texture_by_id(_data.id)
		if texture and texture_rect_item_view:
			texture_rect_item_view.texture = texture
			label_fallback.text = ""
		else:
			texture_rect_item_view.texture = null
			label_fallback.text = _data.name
	get():
		return _data

var is_dragging: bool = false


func _ready() -> void:
	if _pending_des != "":
		label_description.text = _pending_des
		_pending_des = ""
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if _data != null:
		TooltipManager.show_item(_data)

func _on_mouse_exited() -> void:
	TooltipManager.hide_item()


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		print("[EquipmentSlot] _can_drop_data: data is not Dictionary, actual type: ", typeof(data))
		return false
	if not data.has("item_data") or not data.has("from_bag"):
		print("[EquipmentSlot] _can_drop_data: missing item_data or from_bag, data keys: ", data.keys())
		return false
	var item_data: ItemData.ItemInfo = data.get("item_data")
	if not item_data:
		print("[EquipmentSlot] _can_drop_data: item_data is null")
		return false
	print("[EquipmentSlot] _can_drop_data: slot_type=", slot_type, " item=", item_data.name, " match=", _is_item_match_slot(item_data))
	return _is_item_match_slot(item_data)


func _drop_data(_pos: Vector2, data: Variant) -> void:
	print("[EquipmentSlot] _drop_data called: slot_type=", slot_type)
	if not data is Dictionary:
		print("[EquipmentSlot] _drop_data: data is not Dictionary")
		return
	if not data.has("item_data") or not data.has("from_bag"):
		print("[EquipmentSlot] _drop_data: missing item_data or from_bag")
		return
	var item_data: ItemData.ItemInfo = data.get("item_data")
	var from_bag_index: int = data.get("from_bag_index", -1)
	print("[EquipmentSlot] _drop_data: item=", item_data.name if item_data else "null", " from_bag_index=", from_bag_index)
	if not item_data:
		return
	if not _is_item_match_slot(item_data):
		print("[EquipmentSlot] _drop_data: item does not match slot")
		return
	print("[EquipmentSlot] _drop_data: emitting equipment_dropped signal")
	equipment_dropped.emit(slot_type, item_data, from_bag_index)


func _is_item_match_slot(item_data: ItemData.ItemInfo) -> bool:
	match slot_type:
		EquipmentSlotType.WEAPON:
			return item_data is WeaponData.WeaponInfo
		EquipmentSlotType.HELMET:
			return item_data is EquipmentData.EquipmentInfo and item_data.armor_type == EquipmentData.ArmorType.HELMET
		EquipmentSlotType.PAULDRONS:
			return item_data is EquipmentData.EquipmentInfo and item_data.armor_type == EquipmentData.ArmorType.PAULDRONS
		EquipmentSlotType.CHESTPLATE:
			return item_data is EquipmentData.EquipmentInfo and item_data.armor_type == EquipmentData.ArmorType.CHESTPLATE
		EquipmentSlotType.GREAVES:
			return item_data is EquipmentData.EquipmentInfo and item_data.armor_type == EquipmentData.ArmorType.GREAVES
		EquipmentSlotType.BELT:
			return item_data is EquipmentData.EquipmentInfo and item_data.armor_type == EquipmentData.ArmorType.BELT
		EquipmentSlotType.NECKLACE:
			return item_data is EquipmentData.EquipmentInfo and item_data.accessory_type == EquipmentData.AccessoryType.NECKLACE
		EquipmentSlotType.RING1, EquipmentSlotType.RING2:
			return item_data is EquipmentData.EquipmentInfo and item_data.accessory_type == EquipmentData.AccessoryType.RING
	return false


func get_slot_name() -> String:
	match slot_type:
		EquipmentSlotType.WEAPON:
			return "weapon"
		EquipmentSlotType.HELMET:
			return "helmet"
		EquipmentSlotType.PAULDRONS:
			return "pauldrons"
		EquipmentSlotType.CHESTPLATE:
			return "chestplate"
		EquipmentSlotType.GREAVES:
			return "greaves"
		EquipmentSlotType.BELT:
			return "belt"
		EquipmentSlotType.NECKLACE:
			return "necklace"
		EquipmentSlotType.RING1:
			return "ring1"
		EquipmentSlotType.RING2:
			return "ring2"
	return ""


func init(d: ItemData.ItemInfo):
	data = d

func clear():
	data = null
