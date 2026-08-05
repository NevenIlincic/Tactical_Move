extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2]
@onready var player_sprite: Sprite2D = $Player_Sprite
@onready var player_path_line: PlayerPathLine = $Player_Path_Line
@onready var player_look_at_line: PlayerLookAtLine = $Player_Look_At_Line

####PLAYER MOVES
var num_available_steps: int = 50
var num_steps_to_do: int = 0
const SPEED: float = 250
var is_enemy_spotted: bool = false
@onready var look_at_position_sprite: Sprite2D = $Look_At_Position_Sprite

enum EngagementRules {
	IGNORE, #Ignorise i nastavlja dalje
	STOP_AND_SHOT_IN_PASSING, #Staje i puca ako mu je u vidokrugu (bez pracenja rotacijom)
	STOP_AND_SHOT_FOLLOWING, #Staje i puca ako mu je usao u vidokrug (prati neprijatelja rotacijom)
	MOVE_AND_SHOT_IN_PASSING, #Nastavlja kretnju (ako postoji) i samo puca u vidokrugu (bez pracenja rotacijom)
	MOVE_AND_SHOT_FOLLOWING # Nastavlja (ako postoji) i prati rotiranjem dok ne izgubi iz vidokruga
}
@export var current_engagement_rule: EngagementRules = EngagementRules.IGNORE

var enemy_to_shoot: Enemy
var follow_enemy_with_rotation: bool = false
#####
#VISION (FOW)
@onready var vision_polygon: PlayerVision = $Vision_Polygon

var rays: Array[RayCast2D] = []
var point_to_look


func _ready() -> void:
	player_path.append(global_position)
	set_up_lines_data()
	connect_to_signals()
	
func set_up_lines_data():
	player_path_line.add_point(global_position)
	player_look_at_line.add_point(global_position)
	player_look_at_line.set_player_look_at_position_sprite(look_at_position_sprite)

func connect_to_signals():
	Signals.move_player.connect(move)
	Signals.show_enemy.connect(_on_enemy_seen)
	Signals.hide_enemy.connect(_on_enemy_lost)
	
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
	if is_moving:
		if enemy_to_shoot:
			if follow_enemy_with_rotation:
				set_point_to_look(enemy_to_shoot)
			
		set_player_looking_at()
		vision_polygon.update_vision()
		move_player_look_at_line_start_position()
		gradually_remove_path_line()
		#if enemy_to_shoot:
			##print("PUC PUC!")
			#if follow_enemy_with_rotation:
				#look_at(enemy_to_shoot.global_position)
			#else:
				#set_player_looking_at()
		#else:
			#set_player_looking_at()
func gradually_remove_path_line():
	if player_path_line.get_point_count() > 1:
		player_path_line.set_point_position(0, global_position)
		var next_point = player_path_line.get_point_position(1)
		if global_position.distance_to(next_point) < 10.0:
			player_path_line.remove_point(0)
func move_player_look_at_line_start_position():
	if player_look_at_line.get_point_count() > 0:
		player_look_at_line.set_point_position(0, global_position)
func set_player_looking_at():
	if point_to_look:
		if check_is_point_to_look_vector():	
			look_at(point_to_look)
		else:
			look_at(point_to_look.global_position)

func set_point_to_look(point):
	point_to_look = point
	#If point is enemy
	if not check_is_point_to_look_vector():
		point_to_look = point.global_position
		look_at_position_sprite.visible = false
		return
	look_at_position_sprite.visible = true
	look_at_position_sprite.global_position = point_to_look
	if player_look_at_line.get_point_count() == 1:
		player_look_at_line.add_point(point_to_look)
	else:
		player_look_at_line.set_point_position(1, point_to_look)

func reset_point_to_look():
	point_to_look = null
	player_look_at_line.reset_path()
	
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
		var	target_angle = global_position.angle_to_point(point_to_look)
		var start_angle = rotation
		
		tween.tween_method(
			func(weight: float): rotation = lerp_angle(start_angle, target_angle, weight),
			0.0, 1.0, 0.15
		)
	else:
		tween.kill()
func do_movement(tween: Tween):
	var current_position = global_position	
	if len(player_path) > 1:
		for target_position in player_path:
			var distance = current_position.distance_to(target_position)
			var duration = distance / SPEED
			tween.tween_property(self, "global_position", target_position, duration)
			
			current_position = target_position
	else:
		tween.kill()

#Executes when player confirmes end moves
func move(tile_map: TileMapLayer):
	player_look_at_line.reset_path()
	is_moving = true
	#num_available_steps -= num_steps_to_do
	await do_actions()
	on_move_finished()

var rotation_tween: Tween
var move_tween: Tween
func do_actions():
	rotation_tween = create_tween()
	move_tween = create_tween()
	do_initial_player_rotation(rotation_tween)
	do_movement(move_tween)
	if move_tween and move_tween.is_valid():
		await move_tween.finished
	if rotation_tween and rotation_tween.is_valid():
		await rotation_tween.finished

func on_move_finished():
	is_moving = false
	player_path.clear()
	point_to_look = null
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
	if player_path_line.check_can_add_point(point):
		player_path_line.add_point(point)
		player_path.append(point)	


func reset_path():
	player_path.clear()
	player_path.append(global_position)
	player_path_line.reset_path()

func get_line_length(line: Line2D) -> float:
	var total_length: float = 0.0
	var points = line.points
	
	for i in range(points.size() - 1):
		total_length += points[i].distance_to(points[i + 1])
		
	return total_length

func on_engagement_action(enemy: Enemy):
	match current_engagement_rule:
		EngagementRules.IGNORE:
			enemy_to_shoot = null
			return
		EngagementRules.STOP_AND_SHOT_IN_PASSING:
			enemy_to_shoot = enemy
			if move_tween and move_tween.is_valid():
				move_tween.kill()
			reset_path()
		EngagementRules.STOP_AND_SHOT_FOLLOWING:
			enemy_to_shoot = enemy
			follow_enemy_with_rotation = true
			if move_tween and move_tween.is_valid():
				move_tween.kill()
			reset_path()
		EngagementRules.MOVE_AND_SHOT_IN_PASSING:
			enemy_to_shoot = enemy
			follow_enemy_with_rotation = false
		EngagementRules.MOVE_AND_SHOT_FOLLOWING:
			enemy_to_shoot = enemy
			follow_enemy_with_rotation = true
			#follow_enemy_with_rotation = true
func _on_enemy_seen(enemy: Enemy, players: Array[Player]) -> void:
	if self not in players:
		return
	print("VIDIM GA")
	enemy.show_enemy()
	on_engagement_action(enemy)
	
func _on_enemy_lost(enemy: Enemy, players: Array[Player]) -> void:
	if self not in players:
		return
	print("IZGUBIO GA")
	enemy.hide_enemy()
	enemy_to_shoot = null
	point_to_look = null
		#TEST
		#if current_engagement_rule == EngagementRules.STOP_AND_SHOT_IN_PASSING or current_engagement_rule == EngagementRules.STOP_AND_SHOT_FOLLOWING:
			#is_moving = false
