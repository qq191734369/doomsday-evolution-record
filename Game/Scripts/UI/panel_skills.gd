extends Panel

class_name SkillPanelNode

const SKILL_ITEM = preload("uid://cfg1vjmlj5k1w")

@onready var skill_item_talent: SkillItemNode = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/TalentSkill_Slot/SkillItem_Talent
@onready var v_box_container_active_skill_list: VBoxContainer = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_ActiveSkillList
@onready var v_box_container_passive_skill_list: VBoxContainer = $NinePatchRect_BG/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_PassiveSkillList

func update(d: GameData.CharacterInfo):
	if not d:
		return
	_update_talent_skill(d)
	_update_active_skills(d)
	_update_passive_skills(d)

func _update_talent_skill(d: GameData.CharacterInfo):
	if d.talent_skill_id.is_empty():
		skill_item_talent.update_with_skill(null)
		return
	var talent = SkillManager.get_talent_skill(d.talent_skill_id)
	if talent:
		skill_item_talent.update_with_talent(talent, d.talent_level)
	else:
		skill_item_talent.update_with_skill(null)

func _update_active_skills(d: GameData.CharacterInfo):
	for child in v_box_container_active_skill_list.get_children():
		child.queue_free()
	for skill_id in d.active_skill_ids.keys():
		var level = d.active_skill_ids[skill_id]
		var skill = SkillManager.get_active_skill(skill_id)
		var item = SKILL_ITEM.instantiate() as SkillItemNode
		v_box_container_active_skill_list.add_child(item)
		if skill:
			item.update_with_skill(skill, level)

func _update_passive_skills(d: GameData.CharacterInfo):
	for child in v_box_container_passive_skill_list.get_children():
		child.queue_free()
	for skill_id in d.passive_skill_ids.keys():
		var level = d.passive_skill_ids[skill_id]
		var skill = SkillManager.get_passive_skill(skill_id)
		var item = SKILL_ITEM.instantiate() as SkillItemNode
		v_box_container_passive_skill_list.add_child(item)
		if skill:
			item.update_with_skill(skill, level)
