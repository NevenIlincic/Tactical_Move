extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2]
@onready var player_sprite: Sprite2D = $Player_Sprite
@onready var player_path_line: Line2D = $Player_Path_Line
@onready var player_look_at_line: Line2D = $Player_Look_At_Line


##PLAYER MOVES
var num_available_steps: int = 50
var num_steps_to_do: int = 0
const SPEED: float = 250
var is_enemy_spotted: bool = false
@onready var look_at_position_sprite: Sprite2D = $Look_At_Position_Sprite

###
#VISION (FOW)
@onready var vision_polygon: PlayerVision = $Vision_Polygon


var rays: Array[RayCast2D] = []
var point_to_look


func _ready() -> void:
	player_path.append(global_position)
	player_path_line.add_point(global_position)
	player_look_at_line.add_point(global_position)
	Signals.move_player.connect(move)
	vision_polygon.setup_vision_rays()
	
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
	set_player_looking_at()
	if is_moving and player_path_line.get_point_count() > 1:
		player_path_line.set_point_position(0, global_position)
		var next_point = player_path_line.get_point_position(1)
		if global_position.distance_to(next_point) < 10.0:
			player_path_line.remove_point(0)
	
	if is_moving and player_look_at_line.get_point_count() > 1:
		player_look_at_line.set_point_position(0, global_position)

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
	if player_look_at_line.get_point_count() == 1:
		player_look_at_line.add_point(point_to_look)
	else:
		player_look_at_line.set_point_position(1, point_to_look)
	
func check_is_point_to_look_vector() -> bool:
	if point_to_look:
		if point_to_look is Vector2:
			return true
		return false
	return false
func set_player_path(new_path: Array[Vector2]):
	player_path = new_path

func do_initial_player_rotation(tween: Tween):
	if point_to_look:
		var target_angle = global_position.angle_to_point(point_to_look)
		var start_angle = rotation
		
		tween.tween_method(
			func(weight: float): rotation = lerp_angle(start_angle, target_angle, weight),
			0.0, 1.0, 0.15
		)
func do_movement(tween: Tween):
	var current_position = global_position

	for target_position in player_path:
		var distance = current_position.distance_to(target_position)
		var duration = distance / SPEED
		tween.tween_property(self, "global_position", target_position, duration)
		
		
		current_position = target_position
		
func move(tile_map: TileMapLayer):
	is_moving = true
	#num_available_steps -= num_steps_to_do
	var tween: Tween = create_tween()
	do_initial_player_rotation(tween)
	do_movement(tween)
	await tween.finished
	
	is_moving = false
	player_path.clear()
	point_to_look = null
	starting_tile = tile_map.local_to_map(tile_map.to_local(self.global_position))
	#player_path.append(starting_tile)
	player_path.append(global_position)

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

##PATH_LINE
func add_point_to_path(point: Vector2) -> void:
	var line_length: float = get_line_length(player_path_line)
	var new_line_length: float = line_length + point.distance_to(player_path_line.points[-1]) 
	print(new_line_length)
	if new_line_length < 1000:
		player_path_line.add_point(point)
		player_path.append(point)	


func reset_path():
	player_path_line.points = player_path_line.points.slice(0,1)

func get_line_length(line: Line2D) -> float:
	var total_length: float = 0.0
	var points = line.points
	
	# Prolazimo kroz sve tačke i sabiramo rastojanja između svake dve susedne
	for i in range(points.size() - 1):
		total_length += points[i].distance_to(points[i + 1])
		
	return total_length
