extends Node

func ChangeScene(key: Resource):
	get_tree().call_deferred("change_scene_to_packed", key)
