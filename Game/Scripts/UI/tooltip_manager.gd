extends Node

const TOOLTIP_SCENE = preload("res://Game/Scene/UI/ItemTooltip.tscn")

var _tooltip: CanvasLayer = null

func _create_tooltip() -> void:
	if _tooltip == null:
		_tooltip = TOOLTIP_SCENE.instantiate()
		get_tree().root.add_child.call_deferred(_tooltip)

func show_item(item_data: ItemData.ItemInfo) -> void:
	if item_data == null:
		hide()
		return
	_create_tooltip()
	_tooltip.show_item(item_data)

func hide() -> void:
	if _tooltip != null:
		_tooltip.hide_tooltip()
