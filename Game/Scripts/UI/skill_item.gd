extends Panel

class_name SkillItemNode

@onready var icon: NinePatchRect = $SkillBg/Icon
@onready var skill_name: Label = $SkillBg/SkillName
@onready var level: Label = $SkillBg/Level

var data: SkillData.SkillInfo

func update(d: SkillData.SkillInfo):
	data = d
	await ready
	
	# TODO 设置数据
	_update_UI(d)
	

func _update_UI(d: SkillData.SkillInfo):
	pass
