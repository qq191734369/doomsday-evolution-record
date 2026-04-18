extends TextureRect

@onready var texture_rect_item_view: TextureRect = $TextureRect_ItemView

@export var item_database: ItemDatabase

var _data: ItemData
var data: ItemData:
	set(val):
		_data = val
		if not val:
			return
		var id = _data.id
		var texture = item_database.get_texture_by_id("water")
		if texture and texture_rect_item_view:
			texture_rect_item_view.texture = texture
	get():
		return _data
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 初始化数据方法，在节点ready后调用
func init(d: ItemData):
	data = d
