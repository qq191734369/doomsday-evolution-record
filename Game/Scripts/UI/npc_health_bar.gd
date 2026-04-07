extends HBoxContainer

var npc: BaseCharacter

@onready var npc_name_label: Label = $Control/NPCName
@onready var npc_avatar: Sprite2D = $Control/NPCAvatar
@onready var health_bar: ProgressBar = $Node2D/HealthBar

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
	
	if npc_name_label:
		# 使用npc.npc_name而不是npc.name
		if npc.has_method("get_npc_name"):
			npc_name_label.text = npc.get_npc_name()
		elif npc.has("npc_name"):
			npc_name_label.text = npc.npc_name
		else:
			npc_name_label.text = npc.name
	
	if npc_avatar:
		# 加载头像
		var npc_name = ""
		if npc.has_method("get_npc_name"):
			npc_name = npc.get_npc_name()
		elif npc.has("npc_name"):
			npc_name = npc.npc_name
		else:
			npc_name = npc.name
		
		# 构建头像路径
		var avatar_path = "res://Assets/Animation/Characters/" + npc_name + "/Avartar_" + npc_name + ".png"
		var texture = load(avatar_path)
		if texture:
			npc_avatar.texture = texture
		else:
			print("找不到头像: " + avatar_path)
	
	if health_bar:
		health_bar.value = float(npc.data.currentHealth) / float(npc.data.get_max_health()) * 100

func update_health():
	_update_display()

func get_npc() -> BaseCharacter:
	return npc
