extends Node

var party_members: Array[BaseCharacter] = []

# 渲染队伍角色
func render_party_members():
	# 获取DataManager实例
	var data_manager = DataManager
	var game_data = data_manager.get_game_data()
	
	# 清空当前列表
	_clearNpcMembersInstanceList()
	GameManager.game_ui_manager.clearNPCBars()
	
	# 获取队伍列表
	var party_list = game_data.partyList
	if party_list.size() == 0:
		return
	
	# 检查Level节点
	if not get_tree().root.has_node("SceneRoot/Level"):
		print("Error: Level node not found")
		return

	var level = get_tree().root.get_node("SceneRoot/Level")
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
	var game_data = DataManager.game_data
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

	# 让所有NPC都跟随玩家
	if member is NPC:
		# 查找玩家实例
		var player = get_tree().root.get_node("SceneRoot/Level/Player")
		if player:
			# 让NPC跟随玩家
			if member.has_method("set_target"):
				member.set_target(player)
			# 根据NPC在队伍中的位置设置不同的跟随距离
			var npc_index = 0
			for i in range(party_members.size()):
				if party_members[i] is NPC:
					npc_index += 1
			# 基础跟随距离为100，每个NPC递增30
			member.follow_distance = 50 + (npc_index - 1) * 50
			member.stop_distance = 20 + (npc_index - 1) * 20
	# 同时可以广播信号等

func add_member(member: BaseCharacter):
	_clearInvalidMembers()
	_add_member_to_gamedata(member.data.name)
	_add_member_to_instance_list(member)
	GlobalMessageBus.emit_party_change_message(member.data.name, true)

func _remove_from_gamedata(member: BaseCharacter):
	var game_data = DataManager.game_data
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
	# 更新所有NPC的跟随目标和跟随距离
	var npc_index = 0
	for i in range(party_members.size()):
		var m = party_members[i]
		if m is NPC:
			# 让所有NPC都跟随玩家
			var player = get_tree().root.get_node("SceneRoot/Level/Player")
			if player and m.has_method("set_target"):
				m.set_target(player)
			# 根据NPC在队伍中的位置设置不同的跟随距离
			npc_index += 1
			# 基础跟随距离为100，每个NPC递增30
			m.follow_distance = 100 + (npc_index - 1) * 30
			m.stop_distance = 50 + (npc_index - 1) * 20

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
	var member_name = member.data.name
	_remove_from_gamedata(member)
	_remove_from_instance_list(member)
	GlobalMessageBus.emit_party_change_message(member_name, false)
