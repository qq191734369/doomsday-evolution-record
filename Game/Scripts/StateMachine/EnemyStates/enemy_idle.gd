extends State

@onready var polygon_2d: Polygon2D = $"../../Polygon2D"

func update():
	super.update()
	character.updateAnimation()
	if character.global_position.distance_to((character.player as BaseCharacter).global_position) <= character.playerDetectionRadius:
		parentStateMachine.switchTo("Move")

func enter():
	super.enter()
	if character.showDebuggVisual:
		createPolygonCircle()
	else:
		polygon_2d.polygon = PackedVector2Array()
	
func exit():
	super.exit()
	if character.showDebuggVisual:
		polygon_2d.polygon = PackedVector2Array()

func createPolygonCircle():
	var points = PackedVector2Array()
	for i in 36:
		var angle = deg_to_rad(10 * i)
		var pointVector2D = Vector2(cos(angle), sin(angle))
		pointVector2D *= character.playerDetectionRadius
		points.append(pointVector2D)
	
	polygon_2d.polygon = points
