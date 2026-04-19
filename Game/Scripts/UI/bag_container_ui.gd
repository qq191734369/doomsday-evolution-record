extends Panel

class_name BagContainerNode

signal item_swapped(from_idx: int, to_idx: int)
signal tab_changed(tab_type: String)

enum BagTab {EQUIPMENT, CONSUMABLE, MATERIAL}
var current_tab: BagTab = BagTab.EQUIPMENT

# 格子数量
@export var slot_num = 36

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer
@onready var btn_equipment: Button = $TabContainer/Button_Equipment
@onready var btn_consumable: Button = $TabContainer/Button_Consumable
@onready var btn_material: Button = $TabContainer/Button_Material

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

var dragging_slot: BagItemSlot = null
var slots: Array[BagItemSlot] = []
var current_bag_data: Array = []

func _ready():
	btn_equipment.button_down.connect(func(): _on_tab_selected(BagTab.EQUIPMENT))
	btn_consumable.button_down.connect(func(): _on_tab_selected(BagTab.CONSUMABLE))
	btn_material.button_down.connect(func(): _on_tab_selected(BagTab.MATERIAL))
	_update_tab_buttons()

func _update_tab_buttons():
	btn_equipment.button_pressed = current_tab == BagTab.EQUIPMENT
	btn_consumable.button_pressed = current_tab == BagTab.CONSUMABLE
	btn_material.button_pressed = current_tab == BagTab.MATERIAL

func _on_tab_selected(tab: BagTab):
	if current_tab == tab:
		return
	current_tab = tab
	_update_tab_buttons()
	tab_changed.emit(_get_tab_type_name())
	_update_slots()

func _get_tab_type_name() -> String:
	match current_tab:
		BagTab.EQUIPMENT:
			return "equipment"
		BagTab.CONSUMABLE:
			return "consume"
		BagTab.MATERIAL:
			return "materals"
	return "consume"

func _waitDone():
	await get_tree().process_frame
	await get_tree().process_frame

func init_slot(bag_data: Array):
	current_bag_data = bag_data
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
	_update_slots()

func _update_slots():
	for i in slots.size():
		var slot = slots[i] as BagItemSlot
		if i < current_bag_data.size() and current_bag_data[i] != null:
			slot.init(current_bag_data[i], i)
		else:
			slot.clear()

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
