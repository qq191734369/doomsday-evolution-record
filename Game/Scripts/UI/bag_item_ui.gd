extends TextureRect

class_name BagItemSlot

@onready var texture_rect_item_view: TextureRect = $MarginContainer/TextureRect_ItemView
@onready var label_stack_num: Label = $Label_StackNum

@export var item_database: ItemDatabase

var _data: ItemData.ItemInfo
var data: ItemData.ItemInfo:
	set(val):
		_data = val
		if not val:
			return
		var texture = item_database.get_texture_by_id(_data.id)
		if texture and texture_rect_item_view:
			texture_rect_item_view.texture = texture
			label_stack_num.text = str(_data.count)
			print("set slot texture", _data.count, _data.name)
	get():
		return _data
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# 初始化数据方法，在节点ready后调用
func init(d: ItemData.ItemInfo):
	print("init", d.name)
	data = d
