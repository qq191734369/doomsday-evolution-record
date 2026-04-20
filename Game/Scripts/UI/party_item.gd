extends NinePatchRect

class_name PartyItemNode

signal item_dropped_on_character(target_character: GameData.CharacterInfo, item_data: ItemData.ItemInfo, from_bag_index: int)

@onready var label_name: Label = $NinePatchRect_Content/Label_Name
@onready var level_value: Label = $NinePatchRect_Content/Label_Level/Level_Value
@onready var progress_bar_heallth: ProgressBar = $NinePatchRect_Content/ProgressBar_Heallth
@onready var progress_bar_mana: ProgressBar = $NinePatchRect_Content/ProgressBar_Mana
@onready var avartar: AvartarNode = $NinePatchRect_AvartarBg
@onready var active: Label = $Active

signal clicked(party_item: PartyItemNode)

var data: GameData.CharacterInfo
var character: BaseCharacter

func _ready():
	setup_child_mouse_filters(self)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if not data.has("item_data") or not data.has("from_bag"):
		return false
	return data.get("item_data") != null


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return
	if not data.has("item_data") or not data.has("from_bag"):
		return
	var item_data: ItemData.ItemInfo = data.get("item_data")
	var from_bag_index: int = data.get("from_bag_index", -1)
	if not item_data or not self.data:
		return
	item_dropped_on_character.emit(self.data, item_data, from_bag_index)

func setup_child_mouse_filters(node: Node):
	# 递归设置所有子元素的鼠标过滤器
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for child in node.get_children():
		setup_child_mouse_filters(child)

func init(data: BaseCharacter):
	character = data
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
