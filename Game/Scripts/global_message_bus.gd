extends Node

enum MessageType {
	KILL,
	DROP,
	PARTY_CHANGE
}

class Message:
	var type: MessageType
	var timestamp: float
	var template: String
	var args: Array
	var color_args: Array

	func _init(p_type: MessageType, p_template: String, p_args: Array, p_color_args: Array = []) -> void:
		type = p_type
		timestamp = Time.get_ticks_msec() / 1000.0
		template = p_template
		args = p_args
		color_args = p_color_args

var _message_queue: Array[Message] = []
var _max_visible_messages: int = 5
var _message_lifetime: float = 5.0

signal message_received(msg: Message)

func emit_kill_message(character_name: String, scene_name: String, enemy_name: String) -> void:
	var msg = Message.new(
		MessageType.KILL,
		"{0} 在 {1} 击杀了 {2}",
		[character_name, scene_name, enemy_name],
		[Color("#ffd700"), Color("#ffffff"), Color("#ff4444")]
	)
	_add_message(msg)

func emit_drop_message(item_name: String, rarity: int = 0) -> void:
	var rarity_color = _get_rarity_color(rarity)
	var rarity_name = _get_rarity_name(rarity)
	var msg = Message.new(
		MessageType.DROP,
		"掉落 [color={rarity_color}]{rarity}[/color] 道具 [color={rarity_color}]{item}[/color]".format({"rarity_color": "#%02x%02x%02x" % [int(rarity_color.r * 255), int(rarity_color.g * 255), int(rarity_color.b * 255)], "rarity": rarity_name, "item": item_name}),
		[],
		[]
	)
	_add_message(msg)

func emit_party_change_message(member_name: String, joined: bool) -> void:
	var action = "加入了队伍" if joined else "离开了队伍"
	var action_color = Color("#44ff44") if joined else Color("#ff4444")
	var msg = Message.new(
		MessageType.PARTY_CHANGE,
		"{0} {1}",
		[member_name, action],
		[Color("#44aaff"), action_color]
	)
	_add_message(msg)

func _add_message(msg: Message) -> void:
	_message_queue.append(msg)
	message_received.emit(msg)

func get_pending_messages() -> Array[Message]:
	return _message_queue.duplicate()

func clear_expired_messages() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	_message_queue = _message_queue.filter(func(m: Message): return current_time - m.timestamp < _message_lifetime)

func _get_rarity_color(rarity: int) -> Color:
	match rarity:
		0: return Color("#9d9d9d")
		1: return Color("#1eff00")
		2: return Color("#0070dd")
		3: return Color("#a335ee")
		4: return Color("#ff8000")
		_: return Color("#ffffff")

func _get_rarity_name(rarity: int) -> String:
	match rarity:
		0: return "普通"
		1: return "优秀"
		2: return "稀有"
		3: return "史诗"
		4: return "传说"
		_: return "未知"
