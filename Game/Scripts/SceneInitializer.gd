class_name SceneInitializer

# 单例实例
static var singleton: SceneInitializer

# 单例方法
static func get_instance() -> SceneInitializer:
	if not SceneInitializer.singleton:
		SceneInitializer.singleton = SceneInitializer.new()
	return SceneInitializer.singleton

func init(scene_root: Node2D, player_scene: PackedScene = null, npc_scene: PackedScene = null, enemy_scene: PackedScene = null):
	# 初始化玩家
	init_player_in_scene(scene_root)
	## 初始化NPC
	init_npcs_in_scene(scene_root)
	## 初始化敌人
	#init_enemies_in_scene(scene_root, enemy_scene)

# 初始化场景中的玩家
func init_player_in_scene(scene_root: Node2D) -> void:
	# 延迟一帧，确保场景完全加载
	await scene_root.get_tree().process_frame
	
	var player_scene = load("uid://ba6tj4nvsql2e")
	
	# 获取DataManager实例
	var data_manager = DataManager.get_instance()
	
	# 获取玩家数据
	var player_data = data_manager.get_player_data()
	
	# 检查Level节点是否存在
	var level = scene_root.get_node_or_null("Level")
	if not level:
		print("Error: Level node not found in scene")
		return
	
	# 检查是否已有玩家实例
	var existing_player = level.get_node_or_null("Player")
	if existing_player:
		print("Player already exists, updating data")
		# 设置玩家数据
		existing_player.data = player_data
		return
	
	# 如果提供了玩家场景，则实例化新玩家
	if player_scene:
		var player_instance = player_scene.instantiate() as Player
		
		# 设置玩家数据		
		player_instance.data = player_data
		# 添加到Level节点
		level.add_child(player_instance)
		print("Player instantiated and added to Level")
	else:
		print("Warning: Player scene not provided, using existing player if available")

# 初始化场景中的NPC
func init_npcs_in_scene(scene_root: BaseScene) -> void:
	# 延迟一帧，确保场景完全加载
	await scene_root.get_tree().process_frame
	
	var npc_scene = load("uid://cdcmam8w3evcf")
	
	# 获取DataManager实例
	var data_manager = DataManager.get_instance()
	
	# 获取NPC数据
	var npc_data = data_manager.get_game_data().npcDictionary
	
	# 检查Level节点是否存在
	var level = scene_root.get_node_or_null("Level")
	if not level:
		print("Error: Level node not found in scene")
		return
	
	# 检查当前场景名称
	var current_scene = scene_root.scene_name
	
	# 遍历NPC数据，实例化在当前场景的NPC
	for npc_id in npc_data.keys():
		var npc_info = npc_data[npc_id] as GameData.CharacterInfo
		print("npcscene:" + npc_info.scene, "scene" + current_scene)
		# 检查NPC是否在当前场景, 组队中的npc忽略 有单独方法进行渲染
		if not npc_info.inParty and npc_info.scene == current_scene:
			# 检查是否已有该NPC实例
			var existing_npc = level.get_node_or_null(npc_info.name) as NPC
			if existing_npc:
				print("NPC " + npc_info.name + " already exists, updating data")
				existing_npc.data = npc_info
				continue
			
			# 如果提供了NPC场景，则实例化新NPC
			if npc_scene:
				var npc_instance = npc_scene.instantiate() as NPC
				
				# 设置NPC数据
				npc_instance.data = npc_info
				
				# 添加到Level节点
				level.add_child(npc_instance)
				print("NPC " + npc_info.name + " instantiated and added to Level")
			else:
				print("Warning: NPC scene not provided, skipping NPC instantiation")


# 初始化场景中的敌人
func init_enemies_in_scene(scene_root: Node2D, enemy_scene: PackedScene = null) -> void:
	# 延迟一帧，确保场景完全加载
	await scene_root.get_tree().process_frame
	
	# 获取DataManager实例
	var data_manager = DataManager.get_instance()
	
	# 获取敌人数据
	var enemy_data = data_manager.get_game_data().enemyDictionary
	
	# 检查Level节点是否存在
	var level = scene_root.get_node_or_null("Level")
	if not level:
		print("Error: Level node not found in scene")
		return
	
	# 检查EnemyLevel节点是否存在
	var enemy_level = level.get_node_or_null("EnemyLevel")
	if not enemy_level:
		print("Error: EnemyLevel node not found in scene")
		return
	
	# 检查当前场景名称
	var current_scene = scene_root.name
	
	# 遍历敌人数据，实例化在当前场景的敌人
	for enemy_id in enemy_data.keys():
		var enemy_info = enemy_data[enemy_id]
		
		# 检查敌人是否在当前场景
		if enemy_info.scene == current_scene:
			# 检查是否已有该敌人实例
			var existing_enemy = enemy_level.get_node_or_null(enemy_id)
			if existing_enemy:
				print("Enemy " + enemy_id + " already exists, updating data")
				_update_enemy_data(existing_enemy, enemy_info)
				continue
			
			# 如果提供了敌人场景，则实例化新敌人
			if enemy_scene:
				var enemy_instance = enemy_scene.instantiate()
				enemy_instance.name = enemy_id
				
				# 设置敌人数据
				_update_enemy_data(enemy_instance, enemy_info)
				
				# 添加到EnemyLevel节点
				enemy_level.add_child(enemy_instance)
				print("Enemy " + enemy_id + " instantiated and added to EnemyLevel")
			else:
				print("Warning: Enemy scene not provided, skipping enemy instantiation")

# 更新敌人数据
func _update_enemy_data(enemy: Node2D, enemy_data: GameData.EnemyInfo):
	# 更新位置
	if enemy.has_method("set_global_position"):
		enemy.set_global_position(enemy_data.position)
	
	# 更新健康值
	if "maxHealth" in enemy:
		enemy.maxHealth = enemy_data.maxHealth
	if "currentHealth" in enemy:
		enemy.currentHealth = enemy_data.currentHealth
	
	# 更新攻击力
	if "attackDamage" in enemy:
		enemy.attackDamage = enemy_data.attackDamage
	
	# 更新速度
	if "speed" in enemy:
		enemy.speed = enemy_data.speed
	
	# 更新类型
	if "type" in enemy:
		enemy.type = enemy_data.type
