extends Node2D 
class_name Level

@onready var tile_map: TileMapLayer = $TileMaps/TileMap

var selected_player: Player
var confirmed_player_moves: int = 0

var list_occupied_tiles: Array[Vector2i]

var players: Dictionary = {} #Player
var enemies: Dictionary = {} #Enemy
var players_set_for_move: Dictionary = {}
var players_set_for_rotation: Dictionary = {}
var num_finished_player_turns: int = 0

var initial_num_players: int;
var players_killed: int = 0
var initial_num_enemies: int;
var enemies_killed: int = 0

var current_state: State

var cover_points: Array

#BOOLEANS
var is_level_completed: bool = false

#LABELS
@onready var passed_time_label: Label = $CanvasLayer/Timer/Passed_Time_Label
@onready var current_state_label: Label = $CanvasLayer/Current_State_Label

var total_passed_time_millis: int = 0
var total_passed_time_seconds: int = 0
var total_passed_minutes: int = 0
#MENU
@onready var upgrade_menu: UpgradeMenu = $CanvasLayer/UpgradeMenu
@onready var radial_menu: PopupMenu = $CanvasLayer/RadialMenu
@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var end_game_menu: EndGameMenu = $CanvasLayer/EndGameMenu

#FOR CONFIRMATION DIALOG
@onready var confirmation_dialog: ConfirmDialog = $CanvasLayer/ConfirmationDialog
var current_confirm_callback: Callable

#OTHER NODES
@onready var camera_reset_position_marker: Marker2D = $Camera_Reset_Position_Marker
@onready var camera_start_position_marker: Marker2D = $Camera_Start_Position_Marker
@onready var camera: Camera2D = $Camera2D
@onready var player_stats: PlayerStatsHUD = $CanvasLayer/PlayerStats

@onready var fps_label: Label = $CanvasLayer/FPS_Label



func _ready() -> void:
	UpgradeCardsManager.clear_available_permanent_upgrades()
	for player in get_tree().get_nodes_in_group("Player"):
		if player is Player:
			players[player] = true
	cover_points = get_tree().get_nodes_in_group("a_star_point")

	connect_to_signals()
	current_state = PreparationState.new([
		self,
		players_set_for_move,
		players_set_for_rotation
		])
	
	camera.global_position = camera_start_position_marker.global_position
	
	initial_num_players = get_alive_players().size()
	initial_num_enemies = get_alive_enemies().size()
	AudioManager.set_current_level(self)
	AudioManager.play_background_music(AudioManager.BACKGROUND_MUSIC_LEVEL)

	set_vision_polygons()
	
const VISION_POLYGON = preload("uid://bjx1wow4vot1m")
@onready var vision_polygons_node: Node2D = $CanvasGroup/Vision_Polygons_Node

func set_vision_polygons():
	for player: Player in players:
		var vision_polygon: PlayerVisionPolygon = VISION_POLYGON.instantiate()
		vision_polygons_node.add_child(vision_polygon)
		vision_polygon.set_soldier(player)
		
var i: int = 0
func _physics_process(delta: float) -> void:
	fps_label.text = str("FPS: ", Engine.get_frames_per_second())
	#print(Engine.get_frames_per_second())
	
	#VisionManager.handle_enemy_visibility(delta)
	if i == 0:
		current_state.update(delta)
	i = (i+1) % 2
	#if total_passed_time_millis >= 1000.0:
		#total_passed_time_millis = 0.0
		#total_passed_time_seconds += 1
		#if total_passed_time_seconds >= 60:
			#total_passed_time_seconds = 0
			#total_passed_minutes += 1
	#passed_time_label.text = str(total_passed_minutes, ":", total_passed_time_seconds, ":", total_passed_time_millis)
	#
func _process(delta: float) -> void:
	#fps_label.text = str("FPS: ", Engine.get_frames_per_second())
	VisionManager.handle_enemy_visibility(delta)
	if total_passed_time_millis >= 1000.0:
		total_passed_time_millis = 0.0
		total_passed_time_seconds += 1
		if total_passed_time_seconds >= 60:
			total_passed_time_seconds = 0
			total_passed_minutes += 1
	passed_time_label.text = str(total_passed_minutes, ":", total_passed_time_seconds, ":", total_passed_time_millis)
	

func get_alive_players() -> Dictionary:
	var alive_players: Dictionary = {}
	for player in get_tree().get_nodes_in_group("Player"):
		alive_players[player.soldier_id] = player
	return alive_players
	
func get_alive_enemies() -> Dictionary:
	var alive_enemies: Dictionary = {}
	for enemy: Enemy in get_tree().get_nodes_in_group("enemy_node"):
		alive_enemies[enemy.soldier_id] = enemy
	return alive_enemies

func get_alive_soldiers() -> Dictionary:
	var alive_soldiers: Dictionary = {}
	for soldier: Soldier in get_tree().get_nodes_in_group("soldier"):
		alive_soldiers[soldier.soldier_id] = soldier
	return alive_soldiers

func set_level_state(new_state: State):
	if current_state:
		current_state.queue_free()
	current_state = new_state

#func set_occupied_tiles_list():
	#list_occupied_tiles.clear()
	#for player in players:
		#var starting_tile: Vector2i = tile_map.local_to_map(tile_map.to_local(player.global_position))
		#list_occupied_tiles.append(starting_tile)
		
func connect_to_signals():
	Signals.open_upgrade_removal_confirmation_dialog.connect(_on_confirmation_dialog_opened)
	confirmation_dialog.action_confirmed.connect(_on_action_confirmed)
	confirmation_dialog.action_canceled.connect(_on_action_canceled)
			
@onready var path_line: Line2D = $Path_Line
var start_tile: Vector2i = Vector2i(0,0)

var is_drawing: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause_menu") and not is_level_completed:
		pause_menu.show_pause_menu()
	if Input.is_action_just_pressed("reset_camera_position"):
		camera.global_position = camera_start_position_marker.global_position
	#if Input.is_action_just_pressed("quit"):
		#get_tree().quit()
	current_state._unhandled_input(event)

	
func add_point_to_path(point: Vector2) -> void:
	path_line.add_point(point)
func reset_path():
	path_line.points = []

#CAN SWITCH TO ACTION STATE?
func check_can_do_action() -> bool:
	if players_set_for_move.is_empty() and players_set_for_rotation.is_empty():
		return false
	return true

#CONFIRMATION DIALOG ACTIONS
func _on_confirmation_dialog_opened(upgrade_card: UpgradeCard):
	var dialog_text: String = "Are you sure you want to permanently remove this upgrade?"
	confirmation_dialog.set_dialog_label_text(dialog_text)
	confirmation_dialog.visible = true
	current_confirm_callback = func():
		Signals.permanent_upgrade_removed.emit(upgrade_card)
		
func _on_action_confirmed():
	if current_confirm_callback.is_valid():
		current_confirm_callback.call()
		current_confirm_callback = Callable()
	confirmation_dialog.visible = false
func _on_action_canceled():
	current_confirm_callback = Callable()
	confirmation_dialog.visible = false

func level_completed():
	player_stats.disconnect_from_signals()
	is_level_completed = true
	await start_end_game_timer()
	end_game_menu.on_level_completed(self)
func level_failed():
	player_stats.disconnect_from_signals()
	is_level_completed = true
	await start_end_game_timer()
	end_game_menu.on_level_failed(self)

func start_end_game_timer():
	await get_tree().create_timer(1.0).timeout

func get_total_time_label() -> Label:
	return passed_time_label

func get_num_killed_players() -> int:
	return players_killed
func get_num_killed_enemies() -> int:
	return enemies_killed
