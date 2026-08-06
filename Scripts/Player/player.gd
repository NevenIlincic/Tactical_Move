extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
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
var initial_point: Vector2
enum EngagementRules {
	IGNORE, #Ignorise i nastavlja dalje
	STOP_AND_SHOT_IN_PASSING, #Staje i puca ako mu je u vidokrugu (bez pracenja rotacijom)
	STOP_AND_SHOT_FOLLOWING, #Staje i puca ako mu je usao u vidokrug (prati neprijatelja rotacijom)
	MOVE_AND_SHOT_IN_PASSING, #Nastavlja kretnju (ako postoji) i samo puca u vidokrugu (bez pracenja rotacijom)
	MOVE_AND_SHOT_FOLLOWING # Nastavlja (ako postoji) i prati rotiranjem dok ne izgubi iz vidokruga
}
var engagement_strategy: EngagementStrategy
@export var current_engagement_rule: EngagementRules = EngagementRules.IGNORE

var enemy_to_shoot: Enemy
var follow_enemy_with_rotation: bool = false
#####
#VISION (FOW)
@onready var vision_polygon: PlayerVision = $Vision_Polygon

var ray_index: int
var rays: Array[RayCast2D] = []
var point_to_look

var is_walking: bool = false
var is_shooting: bool = false
var enemies_in_sight: Dictionary = {} #{Enemy: true}

@export var weapons: Array[Weapon]
@export var current_weapon: Weapon


func _ready() -> void:
	player_path.append(global_position)
	set_up_lines_data()
	connect_to_signals()
	if not weapons.is_empty():
		current_weapon = weapons[0]
		current_weapon.set_weapon_owner(self)
		
	change_engagement_strategy(current_engagement_rule)
func is_player_walking() -> bool:
	return is_walking
func has_enemies_in_sight() -> bool:
	return not enemies_in_sight.is_empty()
#func is_player_shooting() -> bool:
	#return is_shooting

#Checks if player is in his finished state 
func is_in_finished_state():
	return false
	return not is_player_walking() and not has_enemies_in_sight()

func set_up_lines_data():
	player_path_line.add_point(global_position)
	player_look_at_line.add_point(global_position)
	player_look_at_line.set_player_look_at_position_sprite(look_at_position_sprite)

func connect_to_signals():
	#Signals.move_player.connect(move)
	Signals.show_enemy.connect(_on_enemy_seen)
	Signals.hide_enemy.connect(_on_enemy_lost)
	
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
#Called when ActionState
func do_while_action(delta: float):
	check_is_enemy_in_sight()	
	set_player_looking_at()
	#vision_polygon.update_vision()
	move_player_look_at_line_start_position()
	gradually_remove_path_line()
	if current_weapon:
		current_weapon.update(delta)

func change_engagement_strategy(rule: EngagementRules):
	match rule:
		EngagementRules.IGNORE:
			engagement_strategy = IgnoreEnemyStrategy.new()
		EngagementRules.STOP_AND_SHOT_IN_PASSING:
			engagement_strategy = StopShootPassingStrategy.new()
		EngagementRules.STOP_AND_SHOT_FOLLOWING:
			engagement_strategy = StopShootFollowingStrategy.new()
		EngagementRules.MOVE_AND_SHOT_IN_PASSING:
			engagement_strategy = MoveShootPassingStrategy.new()
		EngagementRules.MOVE_AND_SHOT_FOLLOWING:
			engagement_strategy = MoveShootFollowingStrategy.new()

func check_is_enemy_in_sight():
	if enemy_to_shoot:
		if follow_enemy_with_rotation:
			set_point_to_look(enemy_to_shoot)
	
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
		if not initial_point:
			initial_point = point_to_look
		return
	if not initial_point:
			initial_point = point_to_look
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
func do_actions():
	player_look_at_line.reset_path()
	#num_available_steps -= num_steps_to_do
	await _move()
	_on_move_finished()

var rotation_tween: Tween
var move_tween: Tween
func _move():
	is_walking = true
	rotation_tween = create_tween()
	move_tween = create_tween()
	do_initial_player_rotation(rotation_tween)
	do_movement(move_tween)
	if move_tween and move_tween.is_valid():
		await move_tween.finished
	if rotation_tween and rotation_tween.is_valid():
		await rotation_tween.finished

func _on_move_finished():
	is_walking = false
	player_path.clear()
	point_to_look = null
	player_path.append(global_position)

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

func on_engagement_action(enemy: Enemy):
	if engagement_strategy:
		engagement_strategy.execute(self, enemy)
		
	if not current_weapon.weapon_state is WeaponReloadState:
		if enemy_to_shoot:
			current_weapon.change_weapon_state(WeaponShootState.new())
		else:
			current_weapon.change_weapon_state(WeaponIdleState.new())
	current_weapon.change_enemy_to_shoot(enemy)
	
func _on_enemy_seen(enemy: Enemy, player: Player) -> void:
	if self != player:
		return
	enemy.show_enemy()
	enemies_in_sight[enemy] = true
	on_engagement_action(enemy)
	
func _on_enemy_lost(enemy: Enemy, player: Player) -> void:
	if self != player:
		return
	enemy.hide_enemy()
	if enemies_in_sight.has(enemy):
		enemies_in_sight.erase(enemy)
	
	if enemies_in_sight.is_empty():
		enemy_to_shoot = null
		if not current_weapon.weapon_state is WeaponReloadState:
			current_weapon.change_weapon_state(WeaponIdleState.new())
	else:
		enemy_to_shoot = enemies_in_sight.keys()[0]
		if not current_weapon.weapon_state is WeaponReloadState:
			current_weapon.change_weapon_state(WeaponShootState.new())
	
	current_weapon.change_enemy_to_shoot(enemy_to_shoot)
	point_to_look = initial_point
	rotation_tween = create_tween()
	do_initial_player_rotation(rotation_tween)
	if rotation_tween and rotation_tween.is_valid():
		await rotation_tween.finished
	#point_to_look = null
