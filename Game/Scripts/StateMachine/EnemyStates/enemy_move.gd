extends State

@onready var navigation_agent_2d: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var player_pos_update_timer: Timer = $"../../PlayerPosUpdateTimer"

var direction: Vector2

func update():
	super.update()
	character.updateAnimation()
	if character.global_position.distance_to((character.player as BaseCharacter).global_position) > character.playerDetectionRadius:
		parentStateMachine.switchTo("Idle")


func updatePhysics(delta: float):
	super.updatePhysics(delta)
	direction = character.global_position.direction_to(navigation_agent_2d.get_next_path_position())
	# 判断是否到达
	if navigation_agent_2d.is_target_reached() == false:
		#character.velocity = character.velocity.lerp(direction * character.speed, delta)
		character.velocity = direction * character.speed * delta * 50
		character.move_and_slide()

func enter():
	super.enter()
	player_pos_update_timer.start()
	
func exit():
	super.exit()
	player_pos_update_timer.stop()

# 定时检测玩家位置
func _on_player_pos_update_timer_timeout() -> void:
	navigation_agent_2d.target_position = character.player.global_position

# 敌人之间碰撞避让
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if parentStateMachine.currentState == self && navigation_agent_2d.is_target_reached() == false:
		character.velocity += safe_velocity * get_physics_process_delta_time()
