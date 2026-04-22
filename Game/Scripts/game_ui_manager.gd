extends CanvasLayer

class_name GameUI

const NPC_HEALTH_BAR_SCENE = preload("res://Game/Scene/NPCHealthBar.tscn")

@onready var progress_bar: ProgressBar = $Control_HUD/ProgressBar
@onready var control_game_over: Control = $Control_GameOver
@onready var npc_health_container: VBoxContainer = $Control_HUD/NPCHealthContainer
@onready var control_party_detail: PartyDetailController = $Control_PartyDetail
@onready var global_message_component: GlobalMessageComponent = $GlobalMessageComponent

var ui_layers: Array = []

var npc_health_bars: Dictionary = {}

var has_active_ui_layer: bool:
	get:
		return ui_layers.size() > 0

func _ready() -> void:
	control_game_over.visible = false
	control_party_detail.visible = false
	GameManager.playerHealthUpdated_signal.connect(updateHealthProgressBar)
	GameManager.gameover_signal.connect(showGameOverUI)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_party_ui"):
		togglePartyPanel()

func togglePartyPanel():
	if ui_layers.has(control_party_detail):
		control_party_detail.hide_party_panel()
		ui_layers.remove_at(ui_layers.find(func(d): d == control_party_detail))
	else :
		control_party_detail.show_party_panel()
		ui_layers.append(control_party_detail)

# 接收血量更新信号
func updateHealthProgressBar(currentHealth: int, maxHealth: int):
	progress_bar.value = float(currentHealth) / float(maxHealth) * 100

func showGameOverUI():
	control_game_over.visible = true

# 添加NPC血条
func addNPCHealthBar(npc: BaseCharacter):
	if npc in npc_health_bars:
		return
	
	# 实例化NPC血条场景
	var health_bar_instance = NPC_HEALTH_BAR_SCENE.instantiate()
	health_bar_instance.setup(npc)
	
	npc_health_container.add_child(health_bar_instance)
	npc_health_bars[npc] = health_bar_instance
	
	# 连接NPC血量更新信号
	npc.currentHealthChanged.connect(_on_npc_health_changed.bind(npc))

# 移除NPC血条
func removeNPCHealthBar(npc: BaseCharacter):
	if npc in npc_health_bars:
		var health_bar_instance = npc_health_bars[npc]
		health_bar_instance.queue_free()
		npc_health_bars.erase(npc)
		
		# 断开信号连接
		if npc.currentHealthChanged.is_connected(_on_npc_health_changed):
			npc.currentHealthChanged.disconnect(_on_npc_health_changed)

func clearNPCBars():
	var container = npc_health_container
	npc_health_bars.clear()
	var bars = container.get_children()
	for bar in bars:
		bar.queue_free()
	

# NPC血量变化回调
func _on_npc_health_changed(npc: BaseCharacter):
	if npc in npc_health_bars:
		var health_bar_instance = npc_health_bars[npc]
		health_bar_instance.update_health()

func _on_button_restart_pressed() -> void:
	clearNPCBars()
	
	control_game_over.visible = false
	get_tree().reload_current_scene()
