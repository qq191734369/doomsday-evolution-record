extends Node

const ITEM_TOOLTIP_SCENE = preload("res://Game/Scene/UI/ItemTooltip.tscn")
const SKILL_TOOLTIP_SCENE = preload("res://Game/Scene/UI/SkillTooltip.tscn")

var _item_tooltip: CanvasLayer = null
var _skill_tooltip: SkillTooltip = null

func _create_item_tooltip() -> void:
	if _item_tooltip == null:
		_item_tooltip = ITEM_TOOLTIP_SCENE.instantiate()
		get_tree().root.add_child.call_deferred(_item_tooltip)

func _create_skill_tooltip() -> void:
	if _skill_tooltip == null:
		_skill_tooltip = SKILL_TOOLTIP_SCENE.instantiate()
		get_tree().root.add_child.call_deferred(_skill_tooltip)

func show_item(item_data: ItemData.ItemInfo) -> void:
	if item_data == null:
		hide_item()
		return
	_create_item_tooltip()
	_item_tooltip.show_item(item_data)

func show_skill(skill_data: SkillData.SkillInfo, level: int = 0, is_talent: bool = false) -> void:
	if skill_data == null:
		hide_skill()
		return
	_create_skill_tooltip()
	_skill_tooltip.show_skill(skill_data, level, is_talent)

func hide_item() -> void:
	if _item_tooltip != null:
		_item_tooltip.hide_tooltip()

func hide_skill() -> void:
	if _skill_tooltip != null:
		_skill_tooltip.hide_tooltip()

func hide_all() -> void:
	hide_item()
	hide_skill()
