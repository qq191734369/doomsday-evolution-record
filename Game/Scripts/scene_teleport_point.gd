extends Area2D

@export var target_scene: SceneKey
@export var to_coordinate: Vector2

const MAIN = "uid://bcoovsux82udu"
const TEST = "uid://bd3v2dacrsn4a"

enum SceneKey {
	MAIN,
	TEST
}

var sceneMap: Dictionary[SceneKey, String] = {
	SceneKey.MAIN: MAIN,
	SceneKey.TEST: TEST
}


func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	
	# 设置传送坐标
	if target is Player:
		var target_position = to_coordinate
		var game_data = DataManager.get_instance().game_data
		
		var playerData = game_data.player
		playerData.position = to_coordinate
		
		var party_member = game_data.getNpcPartyMember()
		for id in party_member:
			var memberData: GameData.CharacterInfo = game_data.npcDictionary[id]
			memberData.position = target_position
	
		var res = load(sceneMap[target_scene])
		SceneManager.ChangeScene(res)
