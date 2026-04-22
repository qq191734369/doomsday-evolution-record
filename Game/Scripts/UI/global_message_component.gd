extends Control

class_name GlobalMessageComponent

@export var max_visible_messages: int = 5
@export var message_spacing: float = 5.0
@export var default_lifetime: float = 5.0
@export var fadeout_duration: float = 0.5

@onready var container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

var _active_messages: Array = []
var _tween_map: Dictionary = {}

func _ready() -> void:
	if GlobalMessageBus:
		GlobalMessageBus.message_received.connect(_on_message_received)
	GlobalMessageBus.clear_expired_messages()

func _process(_delta: float) -> void:
	GlobalMessageBus.clear_expired_messages()

func _on_message_received(msg: GlobalMessageBus.Message) -> void:
	_add_message_item(msg)

func _add_message_item(msg: GlobalMessageBus.Message) -> void:
	var item = _create_message_label(msg)
	container.add_child(item)

	_active_messages.append(item)

	while _active_messages.size() > max_visible_messages:
		var oldest = _active_messages.pop_front()
		_fade_out_and_remove(oldest)

	_reposition_messages()

func _create_message_label(msg: GlobalMessageBus.Message) -> RichTextLabel:
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(400, 0)

	var formatted_text = _format_message(msg)
	label.text = formatted_text

	return label

func _format_message(msg: GlobalMessageBus.Message) -> String:
	if msg.args.is_empty():
		return msg.template

	var text = msg.template
	for i in range(msg.args.size()):
		var placeholder = "{%d}" % i
		var value = str(msg.args[i])
		if msg.color_args.size() > i and msg.color_args[i] is Color:
			var color = msg.color_args[i] as Color
			var hex_color = "#%02x%02x%02x" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]
			value = "[color=%s]%s[/color]" % [hex_color, value]
		text = text.replace(placeholder, value)

	return text

func _reposition_messages() -> void:
	for i in range(_active_messages.size()):
		var msg_item = _active_messages[i]
		if msg_item and is_instance_valid(msg_item):
			var target_pos = Vector2(0, i * (msg_item.get_content_height() + message_spacing))
			var tween = create_tween()
			tween.tween_property(msg_item, "position", target_pos, 0.2)

func _fade_out_and_remove(item: Control) -> void:
	if not is_instance_valid(item):
		return

	if item in _tween_map:
		_tween_map[item].kill()
		_tween_map.erase(item)

	var tween = create_tween()
	_tween_map[item] = tween

	tween.tween_property(item, "modulate:a", 0.0, fadeout_duration)
	tween.tween_callback(item.queue_free)
	_tween_map.erase(item)

func clear_all_messages() -> void:
	for item in _active_messages:
		if is_instance_valid(item):
			item.queue_free()
	_active_messages.clear()
	_tween_map.clear()
