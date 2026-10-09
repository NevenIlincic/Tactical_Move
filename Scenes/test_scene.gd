extends Node2D 
class_name Level

@export var LEVEL_NAME: String
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
var is_healing_applied_once: bool = false
var is_upgrade_applied_once: bool = false

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

@onready var fps_label: FPSLabel = $CanvasLayer/FPS_Label
@onready var rewarded_upgrade_card_label: Label = $CanvasLayer/Rewarded_Upgrade_Card_Label

var achievement_manager: AchievementManager
enum DialogType { NONE, UPGRADE, REWARDED_AD }
var current_dialog_type: DialogType = DialogType.NONE

#MOBILE
@onready var mobile_buttons: Node2D = $CanvasLayer/Mobile_Buttons

func _ready() -> void:
	#if OptionVariables.check_is_device_pc():
		#mobile_buttons.visible = false
	
	UpgradeCardsManager.clear_available_permanent_upgrades()
	for player in get_tree().get_nodes_in_group("Player"):
		if player is Player:
			players[player] = true
		if player is MedicPlayer:
			player.healing_applied.connect(_on_medic_healing_applied)
	cover_points = get_tree().get_nodes_in_group("a_star_point")

	connect_to_signals()
	current_state = PreparationState.new([
		self,
		players_set_for_move,
		players_set_for_rotation
		])
	
	camera.global_position = camera_start_position_marker.global_position
	camera._update_color_rect_transform()

	
	initial_num_players = get_alive_players().size()
	initial_num_enemies = get_alive_enemies().size()
	AudioManager.set_current_level(self)
	AudioManager.play_background_music(AudioManager.BACKGROUND_MUSIC_LEVEL)

	set_vision_polygons()
	
	achievement_manager = AchievementManager.new()
	achievement_manager.set_level(self)
	
	##SDK
	Sdk.web_sdk.level_started()
	if Sdk.web_sdk.is_ad_block_enabled:
		upgrade_card_bonus_button.disabled = true
		

	
const VISION_POLYGON = preload("uid://bjx1wow4vot1m")
#@onready var vision_polygons_node: Node2D = $CanvasGroup/Vision_Polygons_Node
@onready var vision_polygons_node: Node2D = $CanvasLayer2/CanvasGroup/Vision_Polygons_Node

func set_vision_polygons():
	for player: Player in players:
		var vision_polygon: PlayerVisionPolygon = VISION_POLYGON.instantiate()
		vision_polygons_node.add_child(vision_polygon)
		vision_polygon.set_soldier(player)
		
var i: int = 0
func _physics_process(delta: float) -> void:
	current_state.update(delta)
	VisionManager.handle_enemy_visibility(delta)
func _process(delta: float) -> void:

	if total_passed_time_millis >= 1000.0:
		total_passed_time_millis = 0.0
		total_passed_time_seconds += 1
		if total_passed_time_seconds >= 60:
			total_passed_time_seconds = 0
			total_passed_minutes += 1
	passed_time_label.text = str(total_passed_minutes, ":", total_passed_time_seconds, ":", total_passed_time_millis)
	#

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
	Signals.permanent_upgrade_applied.connect(_on_permanent_upgrade_applied)
	
	Sdk.web_sdk.rewarded_ad_watched.connect(_on_rewarded_ad_watched)
	Sdk.web_sdk.rewarded_ad_closed_early.connect(_on_rewarded_ad_closed_early)
	Sdk.web_sdk.interstitial_ad_watched.connect(_on_interstitial_ad_watched)
@onready var path_line: Line2D = $Path_Line
var start_tile: Vector2i = Vector2i(0,0)

var is_drawing: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause_menu") and not is_level_completed:
		pause_menu.show_pause_menu()
		Sdk.web_sdk.level_paused()
		
	if Input.is_action_just_pressed("reset_camera_position"):
		camera.global_position = camera_start_position_marker.global_position
		camera._update_color_rect_transform()
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
	if current_dialog_type == DialogType.REWARDED_AD:
		upgrade_card_bonus_button.disabled = false
		current_dialog_type = DialogType.NONE
		
	current_confirm_callback = Callable()
	confirmation_dialog.visible = false

func level_completed():
	player_stats.disconnect_from_signals()
	is_level_completed = true
	await start_end_game_timer()
	check_for_achivements()
	Sdk.web_sdk.level_completed()
	Sdk.web_sdk.save_level_achievements()
	Sdk.web_sdk.show_interstitial_ad()
	end_game_menu.on_level_completed(self)
	disconnect_from_signals()
	
func level_failed():
	player_stats.disconnect_from_signals()
	is_level_completed = true
	await start_end_game_timer()
	Sdk.web_sdk.level_failed()
	Sdk.web_sdk.num_tries_before_ad -= 1
	if Sdk.web_sdk.num_tries_before_ad <= 0:
		Sdk.web_sdk.num_tries_before_ad = 2
		Sdk.web_sdk.show_interstitial_ad()
	end_game_menu.on_level_failed(self)
	disconnect_from_signals()

func start_end_game_timer():
	await get_tree().create_timer(1.0).timeout

func get_total_time_label() -> Label:
	return passed_time_label

func get_num_killed_players() -> int:
	return players_killed
func get_num_killed_enemies() -> int:
	return enemies_killed


func check_for_achivements():
	pass

func disconnect_from_signals(): 
	if Signals.open_upgrade_removal_confirmation_dialog.is_connected(_on_confirmation_dialog_opened):
		Signals.open_upgrade_removal_confirmation_dialog.disconnect(_on_confirmation_dialog_opened)
	if confirmation_dialog.action_confirmed.is_connected(_on_action_confirmed):
		confirmation_dialog.action_confirmed.disconnect(_on_action_confirmed)
	if confirmation_dialog.action_canceled.is_connected(_on_action_canceled):
		confirmation_dialog.action_canceled.disconnect(_on_action_canceled)
	if Signals.permanent_upgrade_applied.is_connected(_on_permanent_upgrade_applied):
		Signals.permanent_upgrade_applied.disconnect(_on_permanent_upgrade_applied)
	
	
func _on_permanent_upgrade_applied(upgrade_card: UpgradeCard):
	if not is_upgrade_applied_once:
		is_upgrade_applied_once = true

func _on_medic_healing_applied():
	if not is_healing_applied_once:
		is_healing_applied_once = true

@onready var upgrade_card_bonus_button: TextureButton = $CanvasLayer/Upgrade_Card_Bonus_Button

func _on_upgrade_card_bonus_button_pressed() -> void:
	if not upgrade_card_bonus_button.disabled:
		current_dialog_type = DialogType.REWARDED_AD
		upgrade_card_bonus_button.disabled = true
		var dialog_text: String = "Watch an AD in order to get bonus upgrade card?"
		confirmation_dialog.set_dialog_label_text(dialog_text)
		confirmation_dialog.visible = true
		current_confirm_callback = func():
			Sdk.web_sdk.show_rewarded_ad()
	
func _on_rewarded_ad_watched():
	if not Sdk.web_sdk.is_ad_block_enabled:
		upgrade_card_bonus_button.disabled = false
		rewarded_upgrade_card_label.visible = true
		get_tree().create_timer(3.0).timeout.connect(
			func(): rewarded_upgrade_card_label.visible = false
		)
	current_dialog_type = DialogType.NONE

func _on_rewarded_ad_closed_early():
	if not Sdk.web_sdk.is_ad_block_enabled:
		upgrade_card_bonus_button.disabled = false
	current_dialog_type = DialogType.NONE

func _on_interstitial_ad_watched():
	pass

@onready var scroll_container: ScrollContainer = $CanvasLayer/ScrollContainer
@onready var controller_button: TextureButton = $CanvasLayer/Controller_Button

func _on_controller_button_pressed() -> void:
	scroll_container.visible = !scroll_container.visible
	controller_button.release_focus()

#MOBILE
@onready var mobile_upgrade_menu_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Upgrade_Menu_Button
@onready var mobile_move_state_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Move_State_Button
@onready var mobile_observation_state_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Observation_State_Button
@onready var mobile_action_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Action_Button
@onready var mobile_pause_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Pause_Button
@onready var mobile_strategy_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Strategy_Button
@onready var mobile_draw_path_button: TextureButton = $CanvasLayer/Mobile_Buttons/Mobile_Draw_Path_Button

signal upgrade_button_pressed_mobile()
signal move_state_button_pressed_mobile()
signal observation_state_button_pressed_mobile()
signal action_button_pressed_mobile()
signal strategy_button_pressed_mobile()
signal draw_button_pressed_mobile()

func _on_mobile_pause_button_pressed() -> void:
	if not is_level_completed:
		pause_menu.show_pause_menu()
		Sdk.web_sdk.level_paused()


func _on_mobile_upgrade_menu_button_pressed() -> void:
	upgrade_button_pressed_mobile.emit()

func _on_mobile_move_state_button_pressed() -> void:
	move_state_button_pressed_mobile.emit()

func _on_mobile_observation_state_button_pressed() -> void:
	observation_state_button_pressed_mobile.emit()


func _on_mobile_action_button_pressed() -> void:
	action_button_pressed_mobile.emit()


func _on_mobile_strategy_button_pressed() -> void:
	strategy_button_pressed_mobile.emit()


func _on_mobile_draw_path_button_pressed() -> void:
	draw_button_pressed_mobile.emit()
