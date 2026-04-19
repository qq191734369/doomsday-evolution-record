extends Panel

class_name BagContainerNode

# 格子数量
@export var slot_num = 36

@onready var grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer

const BAG_ITEM_UI = preload("uid://clidtp6deo8i6")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#init_slot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _waitDone():
	await get_tree().process_frame
	await get_tree().process_frame

# 初始化格子
func init_slot():
	for item in grid_container.get_children():
		item.queue_free()
		
	for i in slot_num:
		var bag_slot = BAG_ITEM_UI.instantiate()
		grid_container.add_child(bag_slot)
		
	await _waitDone()
