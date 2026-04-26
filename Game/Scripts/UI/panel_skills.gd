extends Panel

class_name SkillPanelNode

# 技能槽位场景
const SKILL_ITEM = preload("uid://cfg1vjmlj5k1w")

# 天赋技能
@onready var skill_item_talent: SkillItemNode = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/TalentSkill_Slot/SkillItem_Talent
# 主动技能列表 其中渲染SkillItemNode
@onready var v_box_container_active_skill_list: VBoxContainer = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_ActiveSkillList
# 被动技能列表
@onready var v_box_container_passive_skill_list: VBoxContainer = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_PassiveSkillList

# 更新ui数据
func update(d: BaseCharacter):
	pass
