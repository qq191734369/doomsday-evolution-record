extends ConfirmationDialog

signal split_confirmed(item_data: ItemData.ItemInfo, slot_index: int, split_count: int)

var current_item_data: ItemData.ItemInfo
var current_slot_index: int = -1

@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/SpinBox

func _ready() -> void:
	confirmed.connect(_on_confirmed)

func setup_dialog(item_data: ItemData.ItemInfo, slot_idx: int) -> void:
	current_item_data = item_data
	current_slot_index = slot_idx
	title = "拆分 " + item_data.name
	spin_box.max_value = item_data.count - 1
	spin_box.value = 1
	popup_centered()

func _on_confirmed() -> void:
	var split_count = int(spin_box.value)
	split_confirmed.emit(current_item_data, current_slot_index, split_count)
