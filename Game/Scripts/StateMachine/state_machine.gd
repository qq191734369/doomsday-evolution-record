extends Node

class_name StateMachine

var currentState: State
@onready var debug_label: Label = $"../DebugLabel"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

func _ready() -> void:
	for child in get_children():
		var childState = child as State
		childState.parentStateMachine = self
		childState.character = get_parent() as BaseCharacter
		childState.ready()
	
	# 设置初始状态
	currentState = get_child(0)
	currentState.enter()


func _physics_process(delta: float) -> void:
	currentState.updatePhysics(delta)

	
func _process(_delta: float) -> void:
	currentState.update()
	
func switchTo(targetState: String):
	var nextState = get_node(targetState)
	if !nextState:
		print("cant find " + targetState)
		return
	
	currentState.exit()
	currentState = nextState
	currentState.enter()
