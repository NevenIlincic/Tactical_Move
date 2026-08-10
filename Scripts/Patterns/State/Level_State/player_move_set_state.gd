class_name PlayerSetMoveState extends State

#Data variables
var level: Level

#Other variables
var alive_players: Dictionary 
var is_drawing: bool = false
var player_selection_manager: PlayerSelectionManager
var occupied_target_tiles: Dictionary = {} #{tile: {player_key: true } }
var players_cause_collision: Dictionary = {}

var players_set_for_move: Dictionary = {}
var players_set_for_rotation: Dictionary = {}

func _init(data: Array):
	level = data[0]
	alive_players = level.get_alive_players()
	player_selection_manager = PlayerSelectionManager.new()

	#fill_occupied_target_tiles_dict()

func _unhandled_input(event: InputEvent):
	var selected_player = player_selection_manager.selected_player
	if event is InputEventMouseMotion:
		update_preview()
	if Input.is_action_just_pressed("move_confirm"):
		if player_selection_manager.selected_player:
			player_selection_manager.deselect_player()
		if check_can_do_action():
			#Signals.move_player.emit(level.tile_map)
			level.set_level_state(ActionState.new([level]))
		#else:
			#print(occupied_target_tiles)
		
	if Input.is_action_pressed("drawing"):
		if selected_player:
			if not players_set_for_move.has(selected_player):
				players_set_for_move[selected_player] = true
			is_drawing = true
	else:
		if selected_player:
			is_drawing = false
		
	if Input.is_action_just_pressed("reset_look_at_path") and selected_player:
		selected_player.reset_point_to_look()
		players_set_for_rotation.erase(selected_player)
	
	if Input.is_action_just_pressed("rotate_player_after_move") and selected_player and len(selected_player.player_path) > 1:
		selected_player.set_after_move_looking_point(level.get_global_mouse_position())
	if Input.is_action_just_pressed("reset_rotate_player_after_move") and selected_player:
		selected_player.reset_after_move_looking_point()
	
	if Input.is_action_just_pressed("rotate_player") and selected_player:
		players_set_for_rotation[selected_player] = true
		selected_player.set_point_to_look(level.get_global_mouse_position())
	if Input.is_action_just_pressed("reset_path") and selected_player:
			#_erase_from_occupated_tiles_dict(selected_player.player_path[-1], selected_player)
		selected_player.reset_path()
		players_set_for_move.erase(selected_player)



func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var diff = (a - b).abs()
	return (diff == Vector2i(1, 0)) or (diff == Vector2i(0, 1))

func update_preview() -> void:
	if player_selection_manager.selected_player:
		if is_drawing:
			var mouse_pos = level.tile_map.get_local_mouse_position()
			var target_tile = level.tile_map.local_to_map(mouse_pos)
			#
			if not level.check_is_tile_in_boundsv(target_tile) or level.check_is_tile_solid(target_tile):
				return
			var last_mouse_pos: Vector2 = player_selection_manager.selected_player.player_path[-1]
			if abs(last_mouse_pos.distance_to(mouse_pos)) > 10.0:
				if not is_path_blocked(last_mouse_pos, mouse_pos):
					var mouse_global_position: Vector2 = level.get_global_mouse_position()
					player_selection_manager.selected_player.add_point_to_path(mouse_global_position)	
				

func is_path_blocked(from: Vector2, to: Vector2) -> bool:
	var space_state = level.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	# query.collision_mask = 2 
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return true 
		
	return false


func check_is_players_moving_possible() -> bool:
	for target_tile_dict: Dictionary in occupied_target_tiles.values():
		if len(target_tile_dict) > 1:
			return false
	return true

func _physics_process(delta: float):
	pass

func check_can_do_action() -> bool:
	if players_set_for_move.is_empty() and players_set_for_rotation.is_empty():
		return false
	return true
