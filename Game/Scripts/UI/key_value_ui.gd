@tool

extends HBoxContainer

class_name KeyValueNode

@onready var label_key: Label = $Label_Key
@onready var label_value: Label = $Label_Value
@onready var progress_bar: ProgressBar = $Label_Value/ProgressBar

@export var key: String:
	set(val):
		key = val
		if is_inside_tree() and label_key:
			label_key.text = val

@export var value: String:
	set(val):
		value = val
		if is_inside_tree() and label_value:
			label_value.text = val
			if max_value:
				progress_bar.value = int(val)

var _settings: LabelSettings
@export var settings: LabelSettings:
	set(val):
		_settings = val
		if is_inside_tree() and label_key and label_value:
			label_key.label_settings = val
			label_value.label_settings = val
	get:
		return _settings

@export var max_value: int:
	set(val):
		max_value = val
		if is_inside_tree() and progress_bar:
			progress_bar.max_value = max_value
			progress_bar.visible = true
		elif progress_bar:
			progress_bar.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_inside_tree():
		label_key.text = key
		label_value.text = value
		label_key.label_settings = settings
		label_value.label_settings = settings
		
		if max_value:
			progress_bar.visible = true
			progress_bar.max_value = max_value
			progress_bar.value = int(value)
			
