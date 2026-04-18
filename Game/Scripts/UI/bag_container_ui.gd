extends Panel

class_name BagContainerNode

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

# 默认背包格子数量
const DEFAULT_SLOT_NUM = 36

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_slot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 初始化格子
func init_slot():
	for item in grid_container.get_children():
		item.queue_free()
		
	for i in DEFAULT_SLOT_NUM:
		var bag_slot = BAG_ITEM_UI.instantiate()
		grid_container.add_child(bag_slot)
