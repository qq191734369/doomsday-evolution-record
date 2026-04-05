extends Node

var party_members: Array[BaseCharacter] = []

# 渲染队伍角色
func render_party_members():
	# 获取DataManager实例
	var data_manager = DataManager.get_instance()
	var game_data = data_manager.get_game_data()
	
	# 清空当前列表
	_clearNpcMembersInstanceList()
	GameManager.game_ui_manager.clearNPCBars()
	
	# 获取队伍列表
	var party_list = game_data.partyList
	if party_list.size() == 0:
		return
	
	# 检查Level节点
	var level = get_tree().root.get_node("SceneRoot/Level")
	if not level:
		print("Error: Level node not found")
		return
	
	# 遍历队伍列表，渲染NPC
	for npc_id in party_list:
		# 跳过玩家自己
		if npc_id == "Player":
			continue
		
		# 获取NPC数据
		var npc_data = game_data.get_npc_data(npc_id)
		if not npc_data:
			print("Error: NPC data not found for " + npc_id)
			continue
		
		# 检查是否已有该NPC实例
		var existing_npc = level.get_node_or_null(npc_data.name)
		if existing_npc:
			print("NPC " + npc_data.name + " already exists in scene")
			# 更新NPC数据
			existing_npc.data = npc_data
			# 添加到队伍
			if not is_in_party(existing_npc):
				add_member(existing_npc)
			continue
		
		# 加载NPC场景
		var npc_scene = load("uid://cdcmam8w3evcf")
		if not npc_scene:
			print("Error: NPC scene not found")
			continue
		
		# 实例化NPC
		var npc_instance = npc_scene.instantiate() as NPC
		
		# 设置NPC数据
		npc_instance.data = npc_data
		
		# 添加到Level节点
		level.add_child(npc_instance)
		print("NPC " + npc_data.name + " instantiated and added to Level")
		
		# 添加到队伍
		_add_member_to_instance_list(npc_instance)

func is_in_party(c: BaseCharacter) -> bool:
	return party_members.has(c)

func _add_member_to_gamedata(id: String):
	var game_data = DataManager.get_instance().game_data
	if game_data.isInParty(id):
		return
	
	game_data.partyList.append(id)

func _add_member_to_instance_list(member: BaseCharacter):
	if member == null or party_members.has(member):
		return
	
	for i in party_members.size():
		var d = party_members[i]
		if d.data.name == member.data.name:
			d.queue_free()
			party_members.append(member)
	
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

func add_member(member: BaseCharacter):
	_clearInvalidMembers()
	_add_member_to_gamedata(member.data.name)
	_add_member_to_instance_list(member)

func _remove_from_gamedata(member: BaseCharacter):
	var game_data = DataManager.get_instance().game_data
	var dataIdx = game_data.partyList.find(member.data.name)
	if dataIdx != -1:
		game_data.partyList.remove_at(dataIdx)

func _remove_from_instance_list(member: BaseCharacter):
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

func _clearInvalidMembers():
	var list: Array[BaseCharacter] = []
	for item in party_members:
		if is_instance_valid(item):
			list.append(item)
			
	party_members = list

func _clearNpcMembersInstanceList():
	_clearInvalidMembers()
	
	for i in party_members.size():
		var item = party_members[i]
		if item is NPC:
			_remove_from_instance_list(item)
		

func remove_member(member: BaseCharacter):
	_clearInvalidMembers()
	_remove_from_gamedata(member)
	_remove_from_instance_list(member)
