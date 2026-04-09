extends Node2D

# 物品类
class_name BaseItem

var _data: Variant
var data:
	set(value):
		if value:
			updateData(value)
	get:
		return _data

func updateData(value: Variant):
	_data = value
