extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2i]
@onready var player_sprite: Sprite2D = $Player_Sprite


##PLAYER MOVES
var num_available_steps: int = 50
var num_steps_to_do: int = 0
var is_enemy_spotted: bool = false
@onready var look_at_position_sprite: Sprite2D = $Look_At_Position_Sprite

###
#VISION (FOW)
@onready var vision_polygon: PlayerVision = $Vision_Polygon


var rays: Array[RayCast2D] = []
var point_to_look
var facing_angle := 0 # radians, 0 = facing right

func _ready() -> void:
	Signals.move_player.connect(move)
	vision_polygon.setup_vision_rays()
	
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
	set_player_looking_at()

func set_player_looking_at():
	if is_moving and point_to_look:
		if check_is_point_to_look_vector():	
			look_at(point_to_look)
		else:
			look_at(point_to_look.global_position)

func set_point_to_look(point):
	point_to_look = point
	if not check_is_point_to_look_vector():
		look_at_position_sprite.visible = false
		return
	look_at_position_sprite.global_position = point_to_look
	
func check_is_point_to_look_vector() -> bool:
	if point_to_look:
		if point_to_look is Vector2:
			return true
		return false
	return false
func set_player_path(new_path: Array[Vector2i]):
	player_path = new_path

func do_initial_player_rotation(tween: Tween):
	if point_to_look:
		var target_angle = global_position.angle_to_point(point_to_look)
		var start_angle = rotation
		
		tween.tween_method(
			func(weight: float): rotation = lerp_angle(start_angle, target_angle, weight),
			0.0, 1.0, 0.15
		)
func do_movement(tween: Tween, tile_map: TileMapLayer):
	for tile in player_path:
		var world_position = tile_map.map_to_local(tile)
		tween.tween_property(self, "global_position", world_position, 0.2)		

func move(tile_map: TileMapLayer):
	is_moving = true
	num_available_steps -= num_steps_to_do
	var tween: Tween = create_tween()
	do_initial_player_rotation(tween)
	do_movement(tween, tile_map)
	await tween.finished
	
	is_moving = false
	player_path.clear()
	point_to_look = null
	starting_tile = tile_map.local_to_map(tile_map.to_local(self.global_position))
	player_path.append(starting_tile)
	
func check_has_player_finished_move():
	if not is_moving:
		Signals.player_move_finished.emit()


func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = !is_selected
		if is_selected:
			Signals.set_selected_player.emit(self)
		else:
			Signals.deselect_player.emit()
