extends CanvasLayer

const DIALOG_UI_THEME = preload("uid://gdvjaw4d474l")

var label: Label
var v_box_container: VBoxContainer
var has_options: bool = false

signal option_selected(option_data: Dictionary, ui: CanvasLayer)
signal dialogue_continue()

func _ready():
	# 获取节点
	label = get_node_or_null("Control/Panel/Label")
	v_box_container = get_node_or_null("Control/Panel/VBoxContainer")
	v_box_container.alignment = VBoxContainer.ALIGNMENT_END # 子节点从底部开始排列

func _input(event):
	# 监听攻击键，仅当无选项时触发继续
	if visible and not has_options and event.is_action_pressed("attack"):
		dialogue_continue.emit()

func show_dialogue(text: String, options: Array):
	# 检查节点是否存在
	if not label or not v_box_container:
		push_error("Dialog UI nodes not found")
		return
	
	label.text = text
	# 清空旧选项
	for child in v_box_container.get_children():
		child.queue_free()
	
	# 记录是否有选项
	has_options = options.size() > 0
	
	# 如果有选项，创建选项按钮
	if has_options:
		for opt in options:
			var btn = Button.new()
		
			btn.layout_direction = Control.LAYOUT_DIRECTION_RTL
			btn.theme = DIALOG_UI_THEME
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
			btn.text = opt["text"]
			btn.pressed.connect(_on_option_pressed.bind(opt, self))
			v_box_container.add_child(btn)
	
	visible = true

func _on_option_pressed(opt: Dictionary, ui: CanvasLayer):
	print("点击", opt)
	visible = false
	option_selected.emit(opt, ui)
