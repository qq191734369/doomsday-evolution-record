extends Node2D

@export var player_scene: PackedScene
@export var npc_scene: PackedScene
@export var enemy_scene: PackedScene

func _ready():
	# 获取SceneInitializer实例
	var scene_initializer = SceneInitializer.get_instance()
	
	scene_initializer.init(self, player_scene, npc_scene, enemy_scene)
