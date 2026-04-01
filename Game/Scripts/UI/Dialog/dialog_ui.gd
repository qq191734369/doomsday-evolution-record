extends CanvasLayer

@onready var label: Label = $Control/Panel/Label
@onready var v_box_container: VBoxContainer = $Control/Panel/VBoxContainer

signal option_selected(option_data: Dictionary, ui: CanvasLayer)

func show_dialogue(text: String, options: Array):
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
