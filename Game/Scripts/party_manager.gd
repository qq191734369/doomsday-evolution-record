extends Node

var party_members: Array[BaseCharacter] = []

func is_in_party(c: BaseCharacter) -> bool:
	return party_members.has(c)

func add_member(member: BaseCharacter):
	if member == null:
		return
	party_members.append(member)
	
	# 为NPC添加血条（假设Player是BaseCharacter但不是NPC）
	if member is NPC and GameManager.game_ui_manager:
		GameManager.game_ui_manager.addNPCHealthBar(member)
	
	# 如果是第一个加入的非主角成员，跟随主角；否则跟随前一个成员
	if party_members.size() == 1:
		# 假设主角已在队伍中，此处需要先手动添加主角到数组
		pass
	else:
		var previous = party_members[party_members.size() - 2]
		# 让新成员跟随 previous
		if member.has_method("set_target"):
			member.set_target(previous)
	# 同时可以广播信号等

func remove_member(member: BaseCharacter):
	# 从数组移除，并重新计算跟随链
	var idx = party_members.find(member)
	if idx == -1:
		return
	
	# 移除NPC血条
	if member is NPC and GameManager.game_ui_manager:
		GameManager.game_ui_manager.removeNPCHealthBar(member)
	
	party_members.remove_at(idx)
	# 更新后面成员的 target
	for i in range(idx, party_members.size()):
		var m = party_members[i]
		if i == 0:
			m.set_target(party_members[0])  # 跟随主角
		else:
			m.set_target(party_members[i-1])
