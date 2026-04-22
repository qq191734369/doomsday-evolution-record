extends Node

const DROP_ITEM_SCENE = preload("uid://dgrpbh1xi5hsq")

var dropped_items_container: Node2D

func _ready() -> void:
	dropped_items_container = Node2D.new()
	dropped_items_container.name = "DroppedItems"
	get_tree().root.add_child.call_deferred(dropped_items_container)
	print("DropManager initialized")

func spawn_drop(enemy_pos: Vector2, drop_config: Array) -> void:
	if drop_config.is_empty() or not dropped_items_container:
		return
	var total_weight = 0.0
	for drop in drop_config:
		total_weight += drop.get("weight", 1.0)
	var random_val = randf() * total_weight
	var cumulative_weight = 0.0
	var selected_drop = null
	for drop in drop_config:
		cumulative_weight += drop.get("weight", 1.0)
		if random_val <= cumulative_weight:
			selected_drop = drop
			break
	if not selected_drop:
		return
	var item_id = selected_drop.get("item_id", "")
	var count = selected_drop.get("count", 1)
	var scatter_range = selected_drop.get("scatter_range", 50.0)
	var item_info = create_item_info(item_id)
	if not item_info:
		return
	var dropped_item = DROP_ITEM_SCENE.instantiate()
	dropped_items_container.add_child(dropped_item)
	dropped_item.init(item_info, count)
	dropped_item.scatter_at_position(enemy_pos, scatter_range)
	_emit_drop_message(item_info)

func _emit_drop_message(item_info: ItemData.ItemInfo) -> void:
	if not item_info:
		return
	var rarity = item_info.rarity if "rarity" in item_info else 0
	var item_name = item_info.name if item_info.name else "物品"
	GlobalMessageBus.emit_drop_message(item_name, rarity)

func create_item_info(item_id: String) -> ItemData.ItemInfo:
	var data = {"id": item_id, "name": item_id}
	match item_id:
		"water":
			var info = ItemData.ConsumableItemInfo.new(data)
			info.stackable = true
			return info
		"coin":
			var info = ItemData.MaterialItemInfo.new(data)
			info.stackable = true
			return info
		_:
			var info = ItemData.MaterialItemInfo.new(data)
			info.stackable = true
			return info

func spawn_drop_by_enemy_type(enemy_type: String, enemy_pos: Vector2) -> void:
	var drop_config = get_drop_config_by_enemy_type(enemy_type)
	if drop_config.is_empty():
		return
	spawn_drop(enemy_pos, drop_config)

func get_drop_config_by_enemy_type(enemy_type: String) -> Array:
	match enemy_type:
		"Zombie":
			return [
				{"item_id": "water", "count": 1, "weight": 0.5, "scatter_range": 30.0},
				{"item_id": "coin", "count": 5, "weight": 0.3, "scatter_range": 40.0}
			]
		"Skeleton":
			return [
				{"item_id": "bone", "count": 2, "weight": 0.6, "scatter_range": 30.0}
			]
		_:
			return [
				{"item_id": "coin", "count": 1, "weight": 1.0, "scatter_range": 20.0}
			]

func clear_all_dropped_items() -> void:
	for child in dropped_items_container.get_children():
		child.queue_free()
