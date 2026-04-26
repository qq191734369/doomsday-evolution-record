extends Panel

class_name SkillItemNode

signal mouse_entered_skill(skill_data: SkillData.SkillInfo, level: int, is_talent: bool)
signal mouse_exited_skill()

@onready var icon: NinePatchRect = $SkillBg/Icon
@onready var skill_name: Label = $SkillBg/SkillName
@onready var level: Label = $SkillBg/Level

var data: SkillData.SkillInfo
var skill_level: int = 0
var is_talent: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_talent(talent: SkillData.TalentSkillInfo, lv: int):
	data = talent
	skill_level = lv
	is_talent = true
	if not is_node_ready():
		await ready
	_update_ui(talent.name, lv, talent.max_level)

func update_with_skill(skill: SkillData.SkillInfo, lv: int = 0):
	data = skill
	skill_level = lv
	is_talent = false
	if not is_node_ready():
		await ready
	_update_ui(skill.name if skill else "", lv, skill.max_level)

func _update_ui(name: String, lv: int, max_lv: int):
	if not skill_name or not level:
		return
	skill_name.text = name
	if max_lv > 1 or lv > 0:
		level.text = "Lv:%d/%d" % [lv, max_lv]
	else:
		level.text = ""

func _on_mouse_entered() -> void:
	if data != null:
		TooltipManager.show_skill(data, skill_level, is_talent)

func _on_mouse_exited() -> void:
	TooltipManager.hide_skill()
