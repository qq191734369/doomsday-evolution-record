extends Area2D


@export var target_scene: Resource


func _on_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target is Player:
		SceneManager.ChangeScene(target_scene)
