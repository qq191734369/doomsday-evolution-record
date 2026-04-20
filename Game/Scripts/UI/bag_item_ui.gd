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
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag()
			else:
				_end_drag()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_show_action_menu()

func _start_drag():
	if is_dragging or not _data:
		return
	is_dragging = true
	ghost.texture = texture_rect_item_view.texture
	if not ghost.texture:
		label_fallback_ghost.text = _data.name
	ghost.modulate = Color(1, 1, 1, 0.5)
	ghost.visible = true
	drag_started.emit(self)

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
