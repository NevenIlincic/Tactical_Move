class_name PlayerSetMoveState extends State

#Data variables
var level: Level

#Other variables
var alive_players: Dictionary 
var is_drawing: bool = false
#var player_selection_manager: PlayerSelectionManager
var occupied_target_tiles: Dictionary = {} #{tile: {player_key: true } }
var players_cause_collision: Dictionary = {}

func _init(data: Array):
	level = data[0]

	alive_players = level.get_alive_players()
	level.radial_menu.id_pressed.connect(_on_popup_menu_item_pressed)
	#player_selection_manager = PlayerSelectionManager.new()
	level.move_state_label.visible = true
	#fill_occupied_target_tiles_dict()

func _unhandled_input(event: InputEvent):
	var selected_player = PlayerSelectionManager.selected_player
	#var selected_player = player_selection_manager.selected_player
	if event is InputEventMouseMotion:
		update_preview()
	
	if Input.is_action_just_pressed("switch_to_preparation_state"):
		level.move_state_label.visible = false
		level.set_level_state(PreparationState.new([level]))
		return
	if Input.is_action_just_pressed("upgrade_menu"):
		level.move_state_label.visible = false
		level.set_level_state(UpgradeState.new([level]))
		return
	
	if Input.is_action_just_pressed("move_confirm"):
		if PlayerSelectionManager.selected_player:
			PlayerSelectionManager.deselect_player()
		#print(players_set_for_move)
		if check_can_do_action():
			Signals.action_started.emit()
			level.move_state_label.visible = false
			level.set_level_state(ActionState.new([level]))
			return
	
	if Input.is_action_pressed("drawing"):
		if selected_player:
			is_drawing = true
	else:
		if selected_player:
			is_drawing = false
		
	if Input.is_action_just_pressed("reset_look_at_path") and selected_player:
		selected_player.reset_point_to_look()
		level.players_set_for_rotation.erase(selected_player)
	
	if Input.is_action_just_pressed("rotate_player_after_move") and selected_player and len(selected_player.player_path) > 1:
		selected_player.set_after_move_looking_point(level.get_global_mouse_position())
	if Input.is_action_just_pressed("reset_rotate_player_after_move") and selected_player:
		selected_player.reset_after_move_looking_point()
	
	if Input.is_action_just_pressed("rotate_player") and selected_player:
		level.players_set_for_rotation[selected_player] = true
		selected_player.set_point_to_look(level.get_global_mouse_position())
	if Input.is_action_just_pressed("reset_path") and selected_player:
			#_erase_from_occupated_tiles_dict(selected_player.player_path[-1], selected_player)
		selected_player.reset_path()
		level.players_set_for_move.erase(selected_player)
	
	if Input.is_action_just_pressed("popup") and selected_player:
		level.radial_menu.popup()


func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var diff = (a - b).abs()
	return (diff == Vector2i(1, 0)) or (diff == Vector2i(0, 1))

func update_preview() -> void:
	if PlayerSelectionManager.selected_player:
		if is_drawing:
			var mouse_pos = level.tile_map.get_local_mouse_position()
			var target_tile = level.tile_map.local_to_map(mouse_pos)
			#
			if check_is_mouse_over_wall():
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

func is_path_blocked(from: Vector2, to: Vector2) -> bool:
	var space_state = level.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 2 
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return true 
	
	return false


func check_is_players_moving_possible() -> bool:
	for target_tile_dict: Dictionary in occupied_target_tiles.values():
		if len(target_tile_dict) > 1:
			return false
	return true

func _physics_process(_delta: float):
	pass

func check_can_do_action() -> bool:
	if level.players_set_for_move.is_empty() and level.players_set_for_rotation.is_empty():
		return false
	return true
	
func check_is_mouse_over_wall() -> bool:
	var mouse_global_pos = level.get_global_mouse_position()
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mouse_global_pos
	parameters.collide_with_bodies = true
	# parameters.collision_mask = ...      
	
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
