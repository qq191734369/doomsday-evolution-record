extends HBoxContainer

var npc: BaseCharacter

func _ready():
	# 节点准备好后更新显示
	if npc:
		_update_display()

func setup(npc_character: BaseCharacter):
	npc = npc_character
	# 如果节点已经在场景树中，立即更新显示
	if is_inside_tree():
		_update_display()

func _update_display():
	if not npc:
		return
	
	# 获取子节点
	var npc_name_label = get_node_or_null("NPCName")
	var health_bar = get_node_or_null("HealthBar")
	
	if npc_name_label:
		# 使用npc.npc_name而不是npc.name
		if npc.has_method("get_npc_name"):
			npc_name_label.text = npc.get_npc_name()
		elif npc.has("npc_name"):
			npc_name_label.text = npc.npc_name
		else:
			npc_name_label.text = npc.name
	
	if health_bar:
		health_bar.value = float(npc.currentHealth) / float(npc.maxHealth) * 100

func update_health():
	_update_display()

func get_npc() -> BaseCharacter:
	return npc
