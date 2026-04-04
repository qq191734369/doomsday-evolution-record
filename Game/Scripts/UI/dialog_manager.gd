extends Node

const DIALOG_UI_SCENE = preload("uid://dt1uniqjdtnp6")

# 信号，当对话结束时发出
signal dialogue_finished
signal join_party

# 对话数据字典 { id: node_data }
var dialogue_data: Dictionary = {}
# 当前对话节点ID
var current_id: String = ""
# 是否已经弹出
var is_active: bool = false
# Dialog_UI实例
var dialog_ui_instance: CanvasLayer

func _ready():
	load_dialogue("res://Data/dialogue_npc_join.json")
	# 动态创建Dialog_UI实例
	create_dialog_ui()

func create_dialog_ui():
	# 检查是否已经存在实例
	if dialog_ui_instance:
		return
	
	# 实例化Dialog_UI场景
	dialog_ui_instance = DIALOG_UI_SCENE.instantiate() as CanvasLayer
	
	# 添加到根节点
	get_tree().root.add_child.call_deferred(dialog_ui_instance)
	
	# 初始隐藏
	dialog_ui_instance.visible = false

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

func start_dialogue(start_id: String):
	# 确保Dialog_UI实例存在
	if not dialog_ui_instance:
		create_dialog_ui()
	
	current_id = start_id
	dialog_ui_instance.option_selected.connect(_on_option_selected)
	dialog_ui_instance.dialogue_continue.connect(_on_dialogue_continue)
	_show_current_node()
	dialog_ui_instance.visible = true
	is_active = true

func _show_current_node():
	var node = dialogue_data.get(current_id)
	if not node:
		push_error("Dialogue node not found: ", current_id)
		dialogue_finished.emit()
		return
	
	# 获取选项，如果没有则使用空数组
	var options = node.get("options", [])
	dialog_ui_instance.show_dialogue(node["text"], options)

func _on_option_selected(opt: Dictionary, ui: CanvasLayer):
	# 执行选项附带动作
	for action in opt.get("actions", []):
		execute_action(action)
	
	var next_id = opt.get("next")
	_go_to_next_node(next_id)

func _on_dialogue_continue():
	# 处理无选项节点的继续
	var node = dialogue_data.get(current_id)
	if node:
		var next_id = node.get("next")
		_go_to_next_node(next_id)

func _go_to_next_node(next_id):
	if next_id != null and dialogue_data.has(next_id):
		current_id = next_id
		_show_current_node()
	else:
		# 对话结束
		_end_dialogue()

func _end_dialogue():
	if dialog_ui_instance.option_selected.is_connected(_on_option_selected):
		dialog_ui_instance.option_selected.disconnect(_on_option_selected)
	if dialog_ui_instance.dialogue_continue.is_connected(_on_dialogue_continue):
		dialog_ui_instance.dialogue_continue.disconnect(_on_dialogue_continue)
	dialog_ui_instance.visible = false
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

func _exit_tree():
	# 清理Dialog_UI实例
	if dialog_ui_instance and dialog_ui_instance.is_inside_tree():
		dialog_ui_instance.queue_free()
