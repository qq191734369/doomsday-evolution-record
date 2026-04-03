extends CanvasLayer

var label: Label
var v_box_container: VBoxContainer

signal option_selected(option_data: Dictionary, ui: CanvasLayer)

func _ready():
	# 获取节点
	label = get_node_or_null("Control/Panel/Label")
	v_box_container = get_node_or_null("Control/Panel/VBoxContainer")

func show_dialogue(text: String, options: Array):
	# 检查节点是否存在
	if not label or not v_box_container:
		push_error("Dialog UI nodes not found")
		return
	
	label.text = text
	# 清空旧选项
	for child in v_box_container.get_children():
		child.queue_free()
	
	# 创建新选项按钮
	for opt in options:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.pressed.connect(_on_option_pressed.bind(opt, self))
		v_box_container.add_child(btn)
	
	visible = true

func _on_option_pressed(opt: Dictionary, ui: CanvasLayer):
	print("点击", opt)
	visible = false
	option_selected.emit(opt, ui)
