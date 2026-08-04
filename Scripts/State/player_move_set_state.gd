class_name PlayerSetMoveState extends State

#Data variables
var level: Level
var alive_players: Dictionary 

#Other variables
var is_drawing: bool = false
var player_selection_manager: PlayerSelectionManager
var occupied_target_tiles: Dictionary = {} #{tile: {player_key: true } }
var players_cause_collision: Dictionary = {}


func _init(data: Array):
	level = data[0]
	for player: Player in data[1]:
		alive_players[player] = player.player_path
	player_selection_manager = PlayerSelectionManager.new()
	connect_to_singals()
	#fill_occupied_target_tiles_dict()

func _unhandled_input(event: InputEvent):
	var selected_player = player_selection_manager.selected_player
	if event is InputEventMouseMotion:
		update_preview()
	if Input.is_action_just_pressed("move_confirm"):
		if player_selection_manager.selected_player:
			player_selection_manager.deselect_player()
		if check_is_players_moving_possible():
			Signals.move_player.emit(level.tile_map)
		#else:
			#print(occupied_target_tiles)
		
	if Input.is_action_pressed("drawing"):
		if selected_player:
			is_drawing = true
	else:
		if selected_player:
			is_drawing = false

	if Input.is_action_just_pressed("rotate_player") and selected_player:
		#selected_player.look_at(level.get_global_mouse_position())
		selected_player.set_point_to_look(level.get_global_mouse_position())
	if Input.is_action_just_pressed("reset_path") and selected_player:
			#_erase_from_occupated_tiles_dict(selected_player.player_path[-1], selected_player)
		selected_player.player_path = selected_player.player_path.slice(0, 1)
		selected_player.reset_path()

func connect_to_singals():
	player_selection_manager.player_selection_changed.connect(_on_player_selection_changed)
	player_selection_manager.player_deselected.connect(_on_deselect_player)
func _on_deselect_player(deselected_player: Player):
	pass
	#var target_tile = deselected_player.player_path[-1]
	#_add_to_occupated_tiles_dict(target_tile, deselected_player)
	#level.draw_path()

	

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
					#level.add_point_to_path(level.get_global_mouse_position())
			#if player_selection_manager.selected_player.player_path.size() >= 2 and target_tile == player_selection_manager.selected_player.player_path[-2]:
				#player_selection_manager.selected_player.player_path.remove_at(player_selection_manager.selected_player.player_path.size() - 1)
			#elif is_adjacent(player_selection_manager.selected_player.player_path[-1], target_tile) and player_selection_manager.selected_player.num_available_steps >= len(player_selection_manager.selected_player.player_path):
				#player_selection_manager.selected_player.player_path.append(target_tile)
			#level.draw_path(player_selection_manager.selected_player)
			
	#for player in alive_players:
		#level.draw_path(alive_players[player])

func is_path_blocked(from: Vector2, to: Vector2) -> bool:
	var space_state = level.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	# query.collision_mask = 2 
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return true 
		
	return false

func _on_player_selection_changed(previous_selected_player: Player, new_selected_player: Player):
	pass
	#level.free_tile(new_selected_player.starting_tile)
	#level.free_tile(new_selected_player.player_path[-1])
	#_erase_from_occupated_tiles_dict(new_selected_player.starting_tile, new_selected_player)
	#_erase_from_occupated_tiles_dict(new_selected_player.player_path[-1], new_selected_player)
	
#func _add_to_occupated_tiles_dict(tile: Vector2i, player: Player):
	#if not occupied_target_tiles.has(tile):
		#var new_dict: Dictionary = {player: true}
		#occupied_target_tiles[tile] = new_dict
	#else:
		#var existing_tile_dict: Dictionary = occupied_target_tiles[tile]
		#existing_tile_dict[player] = true
		#occupied_target_tiles[tile] = existing_tile_dict

#func _erase_from_occupated_tiles_dict(tile: Vector2i, player: Player):
	#if not occupied_target_tiles.has(tile):
		#return
	#var tile_dict: Dictionary = occupied_target_tiles[tile]
	#tile_dict.erase(player)
	#if tile_dict.is_empty():
		#occupied_target_tiles.erase(tile)
	#else:
		#occupied_target_tiles[tile] = tile_dict

#func fill_occupied_target_tiles_dict():
	#for player in alive_players:
		#occupied_target_tiles[player.starting_tile] = {player: true}

func check_is_players_moving_possible() -> bool:
	for target_tile_dict: Dictionary in occupied_target_tiles.values():
		if len(target_tile_dict) > 1:
			return false
	return true
	
