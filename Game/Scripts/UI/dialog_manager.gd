extends Node

# 信号，当对话结束时发出
signal dialogue_finished
signal join_party

# 对话数据字典 { id: node_data }
var dialogue_data: Dictionary = {}
# 当前对话节点ID
var current_id: String = ""
# 是否已经弹出
var is_active: bool = false

func _ready():
	load_dialogue("res://data/dialogue_npc_join.json")

func load_dialogue(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if data is Array:
				for node in data:
					dialogue_data[node["id"]] = node
			else:
				push_error("Dialogue data must be an array")
		else:
			push_error("Failed to parse JSON: ", json.get_error_message())
		file.close()

func start_dialogue(start_id: String, ui: CanvasLayer):
	current_id = start_id
	ui.option_selected.connect(_on_option_selected)
	_show_current_node(ui)
	is_active = true

func _show_current_node(ui: CanvasLayer):
	var node = dialogue_data.get(current_id)
	if not node:
		push_error("Dialogue node not found: ", current_id)
		dialogue_finished.emit()
		return
	
	ui.show_dialogue(node["text"], node["options"])

func _on_option_selected(opt: Dictionary, ui: CanvasLayer):
	# 执行选项附带动作
	for action in opt.get("actions", []):
		execute_action(action)
	
	var next_id = opt.get("next")
	if next_id != null and dialogue_data.has(next_id):
		current_id = next_id
		_show_current_node(ui)
	else:
		# 对话结束
		ui.option_selected.disconnect(_on_option_selected)
		dialogue_finished.emit()
		is_active = false

func execute_action(action_name: String):
	# 这里调用游戏逻辑，例如加入队伍
	match action_name:
		"join_party":
			# 假设我们有一个全局的 PartyManager 单例
			# 并且当前对话的 NPC 是触发者，需要通过其他方式传递
			# 简单示例：发射信号让外部处理
			print("执行动作: 加入队伍")
			join_party.emit()
			# 可以发射一个信号，由其他系统监听
			# 或者直接调用 PartyManager.add_member()
		_:
			push_warning("Unknown action: ", action_name)
