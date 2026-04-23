extends Node

const MAX_VISIBLE_MESSAGES: int = 100
const MESSAGE_LIFETIME: float = 5.0

enum MessageType {
	KILL,
	DROP,
	PARTY_CHANGE,
	LEVEL_UP,
	EXP_GAIN
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
var _max_visible_messages: int = MAX_VISIBLE_MESSAGES
var _message_lifetime: float = MESSAGE_LIFETIME

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

func emit_level_up_message(character_name: String, new_level: int, exp_for_next: int, current_exp: int) -> void:
	var exp_text = ""
	if exp_for_next > 0:
		exp_text = "距离下一级还需 {0} 经验".format([exp_for_next])
	else:
		exp_text = "已达到满级"
	var msg = Message.new(
		MessageType.LEVEL_UP,
		"[color=#ffd700]{0} 升级了！[/color] 当前等级: {1}  [color=#44aaff]{2}[/color]".format([character_name, new_level, exp_text]),
		[],
		[]
	)
	_add_message(msg)

func emit_exp_gain_message(character_name: String, exp_amount: int) -> void:
	var msg = Message.new(
		MessageType.EXP_GAIN,
		"[color=#44ff44]+{0}[/color] 经验  {1}".format([exp_amount, character_name]),
		[],
		[]
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
