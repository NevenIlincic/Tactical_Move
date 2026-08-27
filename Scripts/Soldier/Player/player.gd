class_name Player extends Soldier

@export var player_name: String
var starting_tile: Vector2i
var target_tile: Vector2i
var is_selected: bool = false

var is_set_for_move: bool = false
var is_set_for_rotation: bool = false

var is_queued_for_medic_healing: bool = false

var allies_nearby: Dictionary = {} #{PLayer: true}

#LINE PATH NODES
@onready var player_path_line: PlayerPathLine = $Player_Path_Line
@onready var player_look_at_line: PlayerLookAtLine = $Player_Look_At_Line
@onready var player_look_at_line_after_move: Line2D = $Player_Look_At_Line_After_Move

#OTHER NODES
@onready var player_sprite: Sprite2D = $Player_Sprite
@onready var move_to_position_marker: Sprite2D = $Move_To_Position_Marker
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player_avatar: CompressedTexture2D
#HEALING
@onready var healing_needed_sprite: Sprite2D = $Healing_Needed_Sprite
@onready var healing_effect_cross: HealingEffect = $HealingEffect_Cross

####PLAYER MOVES
@onready var look_at_position_sprite: Sprite2D = $Look_At_Position_Sprite
var initial_point: Vector2
enum EngagementRules {
	IGNORE, #Ignorise i nastavlja dalje
	STOP_AND_SHOT_IN_PASSING, #Staje i puca ako mu je u vidokrugu (bez pracenja rotacijom)
	STOP_AND_SHOT_FOLLOWING, #Staje i puca ako mu je usao u vidokrug (prati neprijatelja rotacijom)
	MOVE_AND_SHOT_IN_PASSING, #Nastavlja kretnju (ako postoji) i samo puca u vidokrugu (bez pracenja rotacijom)
	MOVE_AND_SHOT_FOLLOWING # Nastavlja (ako postoji) i prati rotiranjem dok ne izgubi iz vidokruga
}

@export var current_engagement_rule: EngagementRules = EngagementRules.IGNORE

#####
#VISION (FOW)
var rays: Array[RayCast2D] = []
func _ready() -> void:
	super._ready()
	soldier_type = SoldierType.PLAYER
	set_up_lines_data()
	#connect_to_signals()
	
	change_engagement_strategy(current_engagement_rule)
	#MOVE TO POSITION MARKER
	animation_player.play("Position_Marker_Rotation")
	move_to_position_marker.global_position = global_position	


func set_player_sprite():
	const PLAYER_M_4A_1_RIFLE = preload("uid://q7sw1jdmg3ev")
	const PLAYER_SOLDIER_PISTOL = preload("uid://xobgolcljc7w")
	
	if current_weapon is Pistol:
		player_sprite.texture = PLAYER_SOLDIER_PISTOL
	elif current_weapon is m4a1Rifle:
		player_sprite.texture = PLAYER_M_4A_1_RIFLE
	

func set_up_lines_data():
	player_path_line.add_point(global_position)
	player_look_at_line.add_point(global_position)
	player_look_at_line.set_player_look_at_position_sprite(look_at_position_sprite)
	player_look_at_line_after_move.add_point(global_position)

func set_after_move_looking_point(point: Vector2):
	super.set_after_move_looking_point(point)
	if player_look_at_line_after_move.get_point_count() == 1:
		player_look_at_line_after_move.add_point(point)
	else:
		player_look_at_line_after_move.set_point_position(1, point)
func reset_after_move_looking_point():
	super.reset_after_move_looking_point()
	player_look_at_line_after_move.clear_points()
	if len(player_path) > 1:
		player_look_at_line_after_move.add_point(player_path[-1])
	else:
		player_look_at_line_after_move.add_point(global_position)
	
func do_while_action_extra():
	move_player_look_at_line_start_position()
	gradually_remove_path_line()

func change_engagement_strategy(rule: EngagementRules):
	current_engagement_rule = rule
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

func set_engagement_strategy(strategy: EngagementStrategy):
	engagement_strategy = strategy
#func check_is_enemy_in_sight():
	#if enemy_to_shoot:
		#if follow_enemy_with_rotation:
			#set_point_to_look(enemy_to_shoot)
	
func gradually_remove_path_line():
	if player_path_line.get_point_count() > 1:
		player_path_line.set_point_position(0, global_position)
		var next_point = player_path_line.get_point_position(1)
		if global_position.distance_to(next_point) < 10.0:
			player_path_line.remove_point(0)
func move_player_look_at_line_start_position():
	if player_look_at_line.get_point_count() > 0:
		player_look_at_line.set_point_position(0, global_position)

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
	
func set_player_path(new_path: Array[Vector2]):
	player_path = new_path

#Executes when player confirmes end moves
#func do_actions():
	#is_walking = true
	#check_soldier_has_action()
	#player_look_at_line.reset_path()
	#await _move()
	#_on_actions_finished()


	#Signals.player_move_finished.emit(self)
func check_for_temporary_perks():
	UpgradeManager.apply_movement_penalty_perk(self)




func check_soldier_has_action():
	if len(player_path) > 1 or point_to_look:
		Signals.player_move_continued.emit(self)
	else:
		Signals.player_move_finished.emit(self)
func _pre_move_actions():
	check_soldier_has_action()
	player_look_at_line.reset_path()
	
func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_on_mouse_click(event)

func _on_mouse_click(event: InputEvent):
	is_selected = !is_selected
	if is_selected:
		Signals.set_selected_player.emit(self)
	else:
		Signals.deselect_player.emit()

##PATH_LINE
func add_point_to_path(point: Vector2) -> void:
	if player_path_line.check_can_add_point(point, soldier_stats.max_travel_distance.get_value()):
		player_path_line.add_point(point)
		player_path.append(point)
		move_to_position_marker.global_position = point
		player_look_at_line_after_move.set_point_position(0, point)


func reset_path():
	super.reset_path()
	#player_path.clear()
	#player_path.append(global_position)
	player_path_line.reset_path()
	move_to_position_marker.global_position = global_position
	#reset_after_move_looking_point()

func _on_enemy_seen_extra(enemy: Soldier) -> void:
	(enemy as Enemy).show_enemy()
	
func _on_enemy_lost_extra(enemy: Soldier) -> void:
	if not enemy is Player: 
		(enemy as Enemy).hide_enemy()
	#point_to_look = null

func check_is_healing_needed():
	if soldier_stats.HP.base_value < soldier_stats.MAX_HP.base_value:
		return true
	return false

func can_soldier_move():
	if is_queued_for_medic_healing:
		reset_path()
		return false
	return true
	
func _on_ally_detection_area_body_entered(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier != self and body.is_in_group("player_hitbox") and soldier is Player:
		if not allies_nearby.has(soldier):
			allies_nearby[soldier] = true
		if not soldier.allies_nearby.has(self):
			soldier.allies_nearby[self] = true
func _on_ally_detection_area_body_exited(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier != self and body.is_in_group("player_hitbox") and soldier is Player:
		if allies_nearby.has(soldier):
			allies_nearby.erase(soldier)
		if soldier.allies_nearby.has(self):
			soldier.allies_nearby.erase(self)
