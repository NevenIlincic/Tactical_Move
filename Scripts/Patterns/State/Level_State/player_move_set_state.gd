class_name PlayerSetMoveState extends State

#Other variables
var alive_players: Dictionary 
var is_drawing: bool = false
#var player_selection_manager: PlayerSelectionManager
var occupied_target_tiles: Dictionary = {} #{tile: {player_key: true } }
var players_cause_collision: Dictionary = {}

#MOBILE
var is_rotate_player_toggled: bool = false
var is_rotate_player_after_move_toggled: bool = false

func _init(data: Array):
	level = data[0]

	alive_players = level.get_alive_players()
	level.radial_menu.id_pressed.connect(_on_popup_menu_item_pressed)
	#player_selection_manager = PlayerSelectionManager.new()
	level.current_state_label.text = "MOVE STATE"
	#fill_occupied_target_tiles_dict()
	if not OptionVariables.check_is_device_pc():
		check_are_buttons_visible()
		connect_to_mobile_signals()
		level.mobile_move_state_button.visible = false
		level.mobile_observation_state_button.visible = true
		level.mobile_action_button.visible = true
	
	
func connect_to_mobile_signals():
	connect_to_signals_extra()
	level.action_button_pressed_mobile.connect(_on_action_button_pressed_mobile)
	level.upgrade_button_pressed_mobile.connect(_on_upgrade_button_pressed_mobile)
	level.observation_state_button_pressed_mobile.connect(_on_observation_state_button_pressed_mobile)
	level.strategy_button_pressed_mobile.connect(_on_strategy_button_pressed_mobile)
	level.draw_button_pressed_mobile.connect(_on_draw_button_pressed_mobile)
	level.reset_path_button_pressed_mobile.connect(_on_reset_path_button_pressed_mobile)
	level.point_to_look_while_moving_button_pressed_mobile.connect(_on_point_to_look_while_moving_pressed_mobile)
	level.reset_point_to_look_while_moving_button_pressed_mobile.connect(_on_reset_point_to_look_while_moving_button_pressed_mobile)
	level.point_to_look_after_move_button_pressed_mobile.connect(_on_point_to_look_after_move_button_pressed_mobile)
	level.reset_point_to_look_after_move_button_pressed_mobile.connect(_on_reset_point_to_look_after_move_button_pressed_mobile)
	PlayerSelectionManager.player_selection_changed_mobile.connect(_on_player_selected_mobile)
	PlayerSelectionManager.player_deselected.connect(_on_player_deselected_mobile)
	
func _unhandled_input(event: InputEvent):
	var selected_player = PlayerSelectionManager.selected_player
	#var selected_player = player_selection_manager.selected_player
	if OptionVariables.check_is_device_pc():
		if event is InputEventMouseMotion:
			update_preview()
	else:
		if event is InputEventScreenDrag and is_drawing:
			draw_path_mobile(event.position)
	
	if Input.is_action_just_pressed("switch_to_preparation_state"):
		disconnect_from_signals()
		level.set_level_state(PreparationState.new([level]))
		return
	if Input.is_action_just_pressed("upgrade_menu"):
		disconnect_from_signals()
		level.set_level_state(UpgradeState.new([level]))
		return
	
	if Input.is_action_just_pressed("move_confirm"):
		#if PlayerSelectionManager.selected_player:
			#PlayerSelectionManager.deselect_player()
		if check_can_do_action():
			disconnect_from_signals()
			Signals.action_started.emit()
			level.set_level_state(ActionState.new([level]))
			return
	
	if selected_player and not selected_player.is_killed:
		if OptionVariables.check_is_device_pc():
			if Input.is_action_pressed("drawing"):
				is_drawing = true
			else:
				is_drawing = false
		
		if Input.is_action_just_pressed("reset_look_at_path"):
			selected_player.reset_point_to_look()
			level.players_set_for_rotation.erase(selected_player)
		
		if OptionVariables.check_is_device_pc():
			if Input.is_action_just_pressed("rotate_player_after_move") and len(selected_player.player_path) > 1:
				selected_player.set_after_move_looking_point(level.get_global_mouse_position())
		else:
			if is_rotate_player_after_move_toggled and len(selected_player.player_path) > 1:
				selected_player.set_after_move_looking_point(level.get_global_mouse_position())
				level.mobile_reset_point_to_look_after_move_button.visible = true
				
		if Input.is_action_just_pressed("reset_rotate_player_after_move"):
			selected_player.reset_after_move_looking_point()
		
		if OptionVariables.check_is_device_pc():
			if Input.is_action_just_pressed("rotate_player"):
				level.players_set_for_rotation[selected_player] = true
				selected_player.set_point_to_look(level.get_global_mouse_position())
		else:
			if is_rotate_player_toggled:
				level.players_set_for_rotation[selected_player] = true
				selected_player.set_point_to_look(level.get_global_mouse_position())
				level.mobile_reset_point_to_look_while_moving_button.visible = true
				
		if Input.is_action_just_pressed("reset_path"):
				#_erase_from_occupated_tiles_dict(selected_player.player_path[-1], selected_player)
			selected_player.reset_path()
			level.players_set_for_move.erase(selected_player)
		
		if Input.is_action_just_pressed("popup"):
			level.radial_menu.popup()


func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var diff = (a - b).abs()
	return (diff == Vector2i(1, 0)) or (diff == Vector2i(0, 1))

func update_preview() -> void:
	if PlayerSelectionManager.selected_player:
		if is_drawing:
			draw_path_pc()
		
				
					
			#var mouse_pos = level.tile_map.get_local_mouse_position()
			#var target_tile = level.tile_map.local_to_map(mouse_pos)
			##
			#if check_is_mouse_over_wall():
				#return
			##if not level.check_is_tile_in_boundsv(target_tile) or level.check_is_tile_solid(target_tile):
				##return
			#var last_mouse_pos: Vector2 = PlayerSelectionManager.selected_player.player_path[-1]
			#if abs(last_mouse_pos.distance_to(mouse_pos)) > 10.0:
				#if not is_path_blocked(last_mouse_pos, mouse_pos):
					#var mouse_global_position: Vector2 = level.get_global_mouse_position()
					#PlayerSelectionManager.selected_player.add_point_to_path(mouse_global_position)	
					#if not level.players_set_for_move.has(PlayerSelectionManager.selected_player):
						#level.players_set_for_move[PlayerSelectionManager.selected_player] = true

func draw_path_pc():
	var mouse_pos = level.tile_map.get_local_mouse_position()
	#var target_tile = level.tile_map.local_to_map(mouse_pos)
	#
	if check_is_mouse_over_wall(level.get_global_mouse_position()):
		return
	#if not level.check_is_tile_in_boundsv(target_tile) or level.check_is_tile_solid(target_tile):
		#return
	var last_mouse_pos: Vector2 = PlayerSelectionManager.selected_player.player_path[-1]
	if abs(last_mouse_pos.distance_to(mouse_pos)) > 10.0:
		if not is_path_blocked(last_mouse_pos, mouse_pos):
			var mouse_global_position: Vector2 = level.get_global_mouse_position()
			PlayerSelectionManager.selected_player.add_point_to_path(mouse_global_position)	
			if not level.players_set_for_move.has(PlayerSelectionManager.selected_player):
				level.players_set_for_move[PlayerSelectionManager.selected_player] = true

func draw_path_mobile(event_position: Vector2) -> void:
	var touch_global_position: Vector2 = level.get_global_mouse_position()
	
	var touch_pos: Vector2 = level.tile_map.to_local(touch_global_position)
	#var target_tile: Vector2i = level.tile_map.local_to_map(touch_pos)

	if check_is_mouse_over_wall(touch_global_position):
		return

	var selected_player = PlayerSelectionManager.selected_player
	if not selected_player or selected_player.player_path.is_empty():
		return
	
	if not level.mobile_reset_path_button.visible and selected_player.player_path.size() > 1:
		level.mobile_reset_path_button.visible = true
	
	var last_mouse_pos: Vector2 = selected_player.player_path[-1]

	if abs(last_mouse_pos.distance_to(touch_pos)) > 10.0:
		if not is_path_blocked(last_mouse_pos, touch_pos):
			selected_player.add_point_to_path(touch_global_position)
			if not level.players_set_for_move.has(selected_player):
				level.players_set_for_move[selected_player] = true

func is_path_blocked(from: Vector2, to: Vector2) -> bool:
	var space_state = level.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 2 | 8
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return true 
	
	return false


func check_is_players_moving_possible() -> bool:
	for target_tile_dict: Dictionary in occupied_target_tiles.values():
		if len(target_tile_dict) > 1:
			return false
	return true

func update(_delta: float):
	pass

func check_can_do_action() -> bool:
	if level.players_set_for_move.is_empty() and level.players_set_for_rotation.is_empty():
		return false
	return true
	
func check_is_mouse_over_wall(mouse_global_pos: Vector2) -> bool:
	#var mouse_global_pos = level.get_global_mouse_position()
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mouse_global_pos
	parameters.collide_with_bodies = true
	 	
	var space_state = level.get_world_2d().direct_space_state
	var results = space_state.intersect_point(parameters)
	
	for result in results:
		var collider = result.collider
		if collider.is_in_group("wall"):
			return true
	return false

func _on_popup_menu_item_pressed(item_id: int):
	match item_id:
		0:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.IGNORE)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(IgnoreEnemyStrategy.new())
		1:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.STOP_AND_SHOT_IN_PASSING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(StopShootPassingStrategy.new())
		2:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.STOP_AND_SHOT_FOLLOWING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(StopShootFollowingStrategy.new())
		3:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.MOVE_AND_SHOT_IN_PASSING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(MoveShootPassingStrategy.new())
		4:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.MOVE_AND_SHOT_FOLLOWING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(MoveShootFollowingStrategy.new())
	Signals.engagement_strategy_changed.emit(PlayerSelectionManager.selected_player)


#MOBILE
func check_are_buttons_visible():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		level.mobile_strategy_button.visible = true
		level.mobile_draw_path_button.visible = true
		level.mobile_point_to_look_while_moving_button.visible = true
		level.mobile_point_to_look_after_move_button.visible = true

		if selected_player.player_path.size() > 1:
			level.mobile_reset_path_button.visible = true
		else:
			level.mobile_reset_path_button.visible = false
		if selected_player.look_at_position_sprite.visible:
			level.mobile_reset_point_to_look_while_moving_button.visible = true
		else:
			level.mobile_reset_point_to_look_while_moving_button.visible = false
		
		if selected_player.after_move_looking_point != null:
			level.mobile_reset_point_to_look_after_move_button.visible = true
		else:
			level.mobile_reset_point_to_look_after_move_button.visible = false
		
		if selected_player is MedicPlayer:
			level.mobile_healing_button.visible = true
		else:
			level.mobile_healing_button.visible = false
		
func _on_action_button_pressed_mobile():
	if check_can_do_action():
		disconnect_from_signals()
		is_drawing = false
		level.mobile_draw_path_button.set_pressed_no_signal(false)
		level.mobile_point_to_look_while_moving_button.set_pressed_no_signal(false)
		Signals.action_started.emit()
		level.set_level_state(ActionState.new([level]))

func _on_upgrade_button_pressed_mobile():
	disconnect_from_signals()
	is_drawing = false
	level.mobile_draw_path_button.set_pressed_no_signal(false)
	level.mobile_point_to_look_while_moving_button.set_pressed_no_signal(false)
	level.set_level_state(UpgradeState.new([level]))

func _on_observation_state_button_pressed_mobile():
	disconnect_from_signals()
	is_drawing = false
	level.mobile_draw_path_button.set_pressed_no_signal(false)
	level.mobile_point_to_look_while_moving_button.set_pressed_no_signal(false)
	level.set_level_state(PreparationState.new([level]))

func _on_strategy_button_pressed_mobile():
	if PlayerSelectionManager.selected_player and not PlayerSelectionManager.selected_player.is_killed:
		level.radial_menu.popup()


func _on_player_selected_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		level.mobile_strategy_button.visible = true
		level.mobile_point_to_look_while_moving_button.visible = true
		level.mobile_draw_path_button.visible = true
		level.mobile_point_to_look_after_move_button.visible = true
		
		if selected_player.player_path.size() > 1:
			level.mobile_reset_path_button.visible = true
		else:
			level.mobile_reset_path_button.visible = false
		if selected_player.look_at_position_sprite.visible:
			level.mobile_reset_point_to_look_while_moving_button.visible = true
		else:
			level.mobile_reset_point_to_look_while_moving_button.visible = false
		if selected_player.after_move_looking_point != null:
			level.mobile_reset_point_to_look_after_move_button.visible = true
		else:
			level.mobile_reset_point_to_look_after_move_button.visible = false
		
		if selected_player is MedicPlayer:
			level.mobile_healing_button.visible = true
		else:
			level.mobile_healing_button.visible = false
		
func _on_player_deselected_mobile(deselected_player: Player):
	level.mobile_strategy_button.visible = false
	
	level.mobile_draw_path_button.visible = false
	level.mobile_reset_path_button.visible = false
	
	level.mobile_point_to_look_while_moving_button.visible = false
	level.mobile_reset_point_to_look_while_moving_button.visible = false
	
	level.mobile_point_to_look_after_move_button.visible = false
	#level.mobile_reset_point_to_look_after_move_button.visible = false
	
func _on_draw_button_pressed_mobile():
	is_drawing = !is_drawing
	if is_drawing:
		level.can_manipulate_camera_signal.emit(false)
		is_rotate_player_toggled = false
		is_rotate_player_after_move_toggled = false
		level.mobile_point_to_look_while_moving_button.set_pressed_no_signal(false)
		level.mobile_point_to_look_after_move_button.set_pressed_no_signal(false)
	else:
		level.can_manipulate_camera_signal.emit(true)

func _on_point_to_look_while_moving_pressed_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		is_rotate_player_toggled = !is_rotate_player_toggled
		if is_rotate_player_toggled:
			level.can_manipulate_camera_signal.emit(false)
			is_drawing = false
			is_rotate_player_after_move_toggled = false
			level.mobile_draw_path_button.set_pressed_no_signal(false)
			level.mobile_point_to_look_after_move_button.set_pressed_no_signal(false)
		else:
			level.can_manipulate_camera_signal.emit(true)

func _on_point_to_look_after_move_button_pressed_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		is_rotate_player_after_move_toggled = !is_rotate_player_after_move_toggled
		if is_rotate_player_after_move_toggled:
			level.can_manipulate_camera_signal.emit(false)
			is_drawing = false
			is_rotate_player_toggled = false
			level.mobile_draw_path_button.set_pressed_no_signal(false)
			level.mobile_point_to_look_while_moving_button.set_pressed_no_signal(false)
		else:
			level.can_manipulate_camera_signal.emit(true)
		
func _on_reset_path_button_pressed_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		selected_player.reset_path()
		level.players_set_for_move.erase(selected_player)
		level.mobile_reset_path_button.visible = false
		level.mobile_reset_point_to_look_after_move_button.visible = false

func _on_reset_point_to_look_while_moving_button_pressed_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		selected_player.reset_point_to_look()
		level.players_set_for_rotation.erase(selected_player)
		level.mobile_reset_point_to_look_while_moving_button.visible = false

func _on_reset_point_to_look_after_move_button_pressed_mobile():
	var selected_player: Player = PlayerSelectionManager.selected_player
	if selected_player and not selected_player.is_killed:
		selected_player.reset_after_move_looking_point()
		level.mobile_reset_point_to_look_after_move_button.visible = false


func disconnect_from_signals():
	if level.radial_menu.id_pressed.is_connected(_on_popup_menu_item_pressed):
		level.radial_menu.id_pressed.disconnect(_on_popup_menu_item_pressed)
	if level.action_button_pressed_mobile.is_connected(_on_action_button_pressed_mobile):
		level.action_button_pressed_mobile.disconnect(_on_action_button_pressed_mobile)
	if level.radial_menu.id_pressed.is_connected(_on_popup_menu_item_pressed):
		level.radial_menu.id_pressed.disconnect(_on_popup_menu_item_pressed)
	if level.upgrade_button_pressed_mobile.is_connected(_on_upgrade_button_pressed_mobile):
		level.upgrade_button_pressed_mobile.disconnect(_on_upgrade_button_pressed_mobile)
	if level.strategy_button_pressed_mobile.is_connected(_on_strategy_button_pressed_mobile):
		level.strategy_button_pressed_mobile.disconnect(_on_strategy_button_pressed_mobile)
	if level.draw_button_pressed_mobile.is_connected(_on_draw_button_pressed_mobile):
		level.draw_button_pressed_mobile.disconnect(_on_draw_button_pressed_mobile)
	if level.reset_path_button_pressed_mobile.is_connected(_on_reset_path_button_pressed_mobile):
		level.reset_path_button_pressed_mobile.disconnect(_on_reset_path_button_pressed_mobile)
	if level.point_to_look_while_moving_button_pressed_mobile.is_connected(_on_point_to_look_while_moving_pressed_mobile):
		level.point_to_look_while_moving_button_pressed_mobile.disconnect(_on_point_to_look_while_moving_pressed_mobile)
	if level.reset_point_to_look_while_moving_button_pressed_mobile.is_connected(_on_reset_point_to_look_while_moving_button_pressed_mobile):
		level.reset_point_to_look_while_moving_button_pressed_mobile.disconnect(_on_reset_point_to_look_while_moving_button_pressed_mobile)
	if level.point_to_look_after_move_button_pressed_mobile.is_connected(_on_point_to_look_after_move_button_pressed_mobile):
		level.point_to_look_after_move_button_pressed_mobile.disconnect(_on_point_to_look_after_move_button_pressed_mobile)
	if level.reset_point_to_look_after_move_button_pressed_mobile.is_connected(_on_reset_point_to_look_after_move_button_pressed_mobile):
		level.reset_point_to_look_after_move_button_pressed_mobile.disconnect(_on_reset_point_to_look_after_move_button_pressed_mobile)
	if PlayerSelectionManager.player_selection_changed_mobile.is_connected(_on_player_selected_mobile):
		PlayerSelectionManager.player_selection_changed_mobile.disconnect(_on_player_selected_mobile)
	if 	PlayerSelectionManager.player_deselected.is_connected(_on_player_deselected_mobile):
		PlayerSelectionManager.player_deselected.disconnect(_on_player_deselected_mobile)
