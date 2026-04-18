extends NinePatchRect

class_name PartyItemNode

@onready var label_name: Label = $NinePatchRect_Content/Label_Name
@onready var level_value: Label = $NinePatchRect_Content/Label_Level/Level_Value
@onready var progress_bar_heallth: ProgressBar = $NinePatchRect_Content/ProgressBar_Heallth
@onready var progress_bar_mana: ProgressBar = $NinePatchRect_Content/ProgressBar_Mana
@onready var avartar: AvartarNode = $NinePatchRect_AvartarBg
@onready var active: Label = $Active

# 信号，当点击时发出
signal clicked(party_item: PartyItemNode)

var data: GameData.CharacterInfo

func _ready():
	# 设置所有子元素的鼠标过滤器为忽略，这样点击会穿透到父元素
	setup_child_mouse_filters(self)

func setup_child_mouse_filters(node: Node):
	# 递归设置所有子元素的鼠标过滤器
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for child in node.get_children():
		setup_child_mouse_filters(child)

func init(data: BaseCharacter):
	self.data = data.data
	update(data)
	
func setActive(val: bool):
	active.visible = val

func update(data: BaseCharacter):
	self.data = data.data
	avartar.avartar_texture = load("res://Assets/Animation/Characters/{name}/Avartar_{name}.png".format({ "name": data.data.name }))
	label_name.text = data.data.name
	level_value.text = str(data.data.level)
	progress_bar_heallth.value = float(data.currentHealth) / float(data.maxHealth) * 100
	progress_bar_mana.value = float(data.currentMana) / float(data.maxMana) * 100

func _gui_input(event):
	# 处理鼠标点击事件
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
