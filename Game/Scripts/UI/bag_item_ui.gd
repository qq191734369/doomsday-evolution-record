extends TextureRect

class_name BagItemSlot

signal drag_started(slot: BagItemSlot)
signal drag_ended(from_slot: BagItemSlot)
signal item_right_clicked(item_data: ItemData.ItemInfo, slot_index: int)

@onready var texture_rect_item_view: TextureRect = $MarginContainer/TextureRect_ItemView
@onready var label_stack_num: Label = $Label_StackNum
@onready var ghost: TextureRect = $Ghost
@onready var label_fallback: Label = $Label_Fallback
@onready var label_fallback_ghost: Label = $Ghost/Label_Fallback_Ghost

@export var item_database: ItemDatabase

var slot_index: int = -1
var _data: ItemData.ItemInfo
var data: ItemData.ItemInfo:
	set(val):
		if not item_database:
			return
		_data = val
		if not val:
			texture_rect_item_view.texture = null
			label_stack_num.text = ""
			label_fallback.text = ""
			return
		var texture = item_database.get_texture_by_id(_data.id)
		if texture and texture_rect_item_view:
			texture_rect_item_view.texture = texture
			if _data.count > 1:
				label_stack_num.text = str(_data.count)
			else:
				label_stack_num.text = ""
			label_fallback.text = ""
		else:
			texture_rect_item_view.texture = null
			label_fallback.text = _data.name
			if _data.count > 1:
				label_stack_num.text = str(_data.count)
			else:
				label_stack_num.text = ""
	get():
		return _data

var is_dragging: bool = false

func _ready():
	ghost.visible = false
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	if not _data:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_show_action_menu()

func _get_drag_data(_pos: Vector2) -> Variant:
	if not _data:
		return false
	var drag_data = {
		"item_data": _data,
		"from_bag": true,
		"from_bag_index": slot_index,
		"from_slot": self
	}
	var preview = TextureRect.new()
	preview.texture = texture_rect_item_view.texture
	if not preview.texture:
		var label = Label.new()
		label.text = _data.name
		preview.add_child(label)
	preview.size = Vector2(48, 48)
	var control = Control.new()
	control.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(control)
	return drag_data


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if not data.has("item_data"):
		return false
	return true


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return
	if not data.has("item_data"):
		return
	var item_data: ItemData.ItemInfo = data.get("item_data")
	var from_bag_index: int = data.get("from_bag_index", -1)
	if not item_data:
		return
	item_dropped.emit(item_data, slot_index, from_bag_index)


signal item_dropped(item_data: ItemData.ItemInfo, to_slot_index: int, from_slot_index: int)

func _end_drag():
	if not is_dragging:
		return
	is_dragging = false
	ghost.visible = false
	label_fallback_ghost.text = ""
	drag_ended.emit(self)

func _process(_delta: float):
	if is_dragging:
		ghost.global_position = ghost.get_global_mouse_position() - ghost.size / 2

func _show_action_menu():
	item_right_clicked.emit(_data, slot_index)

func init(d: ItemData.ItemInfo, idx: int):
	slot_index = idx
	data = d

func clear():
	data = null
