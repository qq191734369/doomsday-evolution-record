extends NinePatchRect

class_name PartyItemNode

@onready var label_name: Label = $NinePatchRect_Content/Label_Name
@onready var level_value: Label = $NinePatchRect_Content/Label_Level/Level_Value
@onready var progress_bar_heallth: ProgressBar = $NinePatchRect_Content/ProgressBar_Heallth
@onready var progress_bar_mana: ProgressBar = $NinePatchRect_Content/ProgressBar_Mana
@onready var avartar: TextureRect = $NinePatchRect_AvartarBg/Avartar
@onready var active: Label = $Active

func init(data: BaseCharacter):
	update.call_deferred(data)
	
func setActive(val: bool):
	active.visible = val

func update(data: BaseCharacter):
	avartar.texture = load("res://Assets/Animation/Characters/{name}/Avartar_{name}.png".format({ "name": data.data.name }))
	label_name.text = data.data.name
	level_value.text = str(data.data.level)
	progress_bar_heallth.value = float(data.currentHealth) / float(data.maxHealth) * 100
	progress_bar_mana.value = float(data.currentMana) / float(data.maxMana) * 100
