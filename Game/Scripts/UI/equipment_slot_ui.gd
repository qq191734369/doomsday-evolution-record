extends TextureRect

class_name EquipmentSlotNode

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


var _pending_des: String = ""


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
	

func init(d: ItemData.ItemInfo):
	data = d

func clear():
	data = null
