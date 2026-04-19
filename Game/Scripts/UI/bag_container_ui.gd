extends Panel

class_name BagContainerNode

signal item_swapped(from_idx: int, to_idx: int)

# 格子数量
@export var slot_num = 36

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

var dragging_slot: BagItemSlot = null
var slots: Array[BagItemSlot] = []

func _ready():
	pass

func _waitDone():
	await get_tree().process_frame
	await get_tree().process_frame

func init_slot():
	for item in grid_container.get_children():
		item.queue_free()
	slots.clear()

	for i in slot_num:
		var bag_slot = BAG_ITEM_UI.instantiate()
		grid_container.add_child(bag_slot)
		slots.append(bag_slot)
		bag_slot.slot_index = i
		bag_slot.drag_started.connect(_on_slot_drag_started)
		bag_slot.drag_ended.connect(_on_slot_drag_ended)

	await _waitDone()

func _on_slot_drag_started(slot: BagItemSlot):
	dragging_slot = slot

func _on_slot_drag_ended():
	if dragging_slot:
		var target_slot = _get_slot_under_mouse()
		if target_slot and target_slot != dragging_slot:
			_swap_slots(dragging_slot, target_slot)
	dragging_slot = null

func _get_slot_under_mouse() -> BagItemSlot:
	var mouse_pos = grid_container.get_global_mouse_position()
	for slot in slots:
		if slot.get_global_rect().has_point(mouse_pos):
			return slot
	return null

func _swap_slots(from_slot: BagItemSlot, to_slot: BagItemSlot):
	var from_idx = from_slot.slot_index
	var to_idx = to_slot.slot_index
	var from_data = from_slot.data
	var to_data = to_slot.data
	from_slot.data = to_data
	to_slot.data = from_data
	item_swapped.emit(from_idx, to_idx)
