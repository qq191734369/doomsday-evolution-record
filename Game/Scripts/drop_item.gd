extends Area2D

class_name DropItem

signal item_picked_up(item: DropItem)

@export var pick_up_range: float = 50.0
@export var item_database: ItemDatabase

var item_data: ItemData.ItemInfo
var count: int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pick_up_area: Area2D = $PickUpArea
@onready var tween: Tween
@onready var label: Label = $Label

var is_picked_up: bool = false
var is_nearby_player: bool = false

func _ready() -> void:
	pick_up_area.body_entered.connect(_on_pick_up_area_body_entered)
	pick_up_area.body_exited.connect(_on_pick_up_area_body_exited)
	connect("body_entered", _on_body_entered)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if item_data != null:
		TooltipManager.show_item(item_data)

func _on_mouse_exited() -> void:
	TooltipManager.hide()

func init(info: ItemData.ItemInfo, cnt: int = 1) -> void:
	item_data = info
	count = cnt
	update_texture()
	add_to_group("dropped_items")

func update_texture() -> void:
	if not item_data:
		return
	var texture = null
	if item_database:
		texture = item_database.get_texture_by_id(item_data.id)
	if texture:
		sprite_2d.texture = texture
	else:
		label.text = item_data.name
		label.visible = true

func scatter_at_position(pos: Vector2, scatter_range: float = 50.0) -> void:
	global_position = pos
	var random_offset = Vector2(
		randf_range(-scatter_range, scatter_range),
		randf_range(-scatter_range, scatter_range)
	)
	var target_pos = pos + random_offset
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.3).set_ease(Tween.EASE_OUT)

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		is_nearby_player = true

func _on_pick_up_area_body_exited(body: Node2D) -> void:
	if body is Player:
		is_nearby_player = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		pick_up_by(body)

func can_be_picked_up() -> bool:
	return not is_picked_up and is_nearby_player

func pick_up_by(player: Player) -> void:
	if is_picked_up:
		return
	is_picked_up = true
	item_picked_up.emit(self)
	var character = player as BaseCharacter
	var success = BagManager.add_item_data(character, item_data, count)
	if success:
		queue_free()
	else:
		is_picked_up = false
		print("背包已满，无法拾取")

static func get_nearest_drop_item(pos: Vector2, max_distance: float = 100.0) -> DropItem:
	var nearest: DropItem = null
	var min_dist = max_distance
	for dropped_item in Engine.get_main_loop().get_nodes_in_group("dropped_items"):
		if dropped_item is DropItem and not dropped_item.is_picked_up:
			var dist = pos.distance_to(dropped_item.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = dropped_item
	return nearest
