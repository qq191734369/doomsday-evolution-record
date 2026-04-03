extends CanvasLayer

@onready var progress_bar: ProgressBar = $Control_HUD/ProgressBar
@onready var control_game_over: Control = $Control_GameOver

func _ready() -> void:
	control_game_over.visible = false
	GameManager.playerHealthUpdated_signal.connect(updateHealthProgressBar)
	GameManager.gameover_signal.connect(showGameOverUI)

# 接收血量更新信号
func updateHealthProgressBar(currentHealth: int, maxHealth: int):
	progress_bar.value = float(currentHealth) / float(maxHealth) * 100

func showGameOverUI():
	control_game_over.visible = true


func _on_button_restart_pressed() -> void:
	control_game_over.visible = false
	get_tree().reload_current_scene()
