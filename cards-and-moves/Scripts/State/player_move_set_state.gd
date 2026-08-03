class_name PlayerSetMoveState extends State

#Data variables
var level: Level

#Other variables
var is_drawing: bool = false
var player_selection_manager: PlayerSelectionManager

func _init(data: Array):
	level = data[0]
	player_selection_manager = PlayerSelectionManager.new()
	connect_to_singals()

func _unhandled_input(event: InputEvent):
	var selected_player = player_selection_manager.selected_player
	if event is InputEventMouseMotion:
		update_preview()
	if Input.is_action_just_pressed("move_confirm"):
		Signals.move_player.emit(level.tile_map)
		
	if Input.is_action_pressed("drawing"):
		if selected_player:
			is_drawing = true
	else:
		if selected_player:
			is_drawing = false

	if Input.is_action_pressed("rotate_player") and selected_player:
		selected_player.look_at(level.get_global_mouse_position())
	
	if Input.is_action_just_pressed("reset_path") and selected_player:
		level.occupy_tile(selected_player.starting_tile)
		if len(selected_player.player_path) > 1:
			print("OVDE")
			level.free_tile(selected_player.player_path[-1])
			selected_player.player_path = selected_player.player_path.slice(0, 1)
		level.draw_path()

func connect_to_singals():
	player_selection_manager.player_selection_changed.connect(_on_player_selection_changed)
	player_selection_manager.player_deselected.connect(_on_deselect_player)
func _on_deselect_player(deselected_player: Player):
	if len(deselected_player.player_path) > 1:
		level.occupy_tile(deselected_player.player_path[-1])
	else:
		level.occupy_tile(deselected_player.starting_tile)
	level.draw_path()

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var diff = (a - b).abs()
	return (diff == Vector2i(1, 0)) or (diff == Vector2i(0, 1))

func update_preview() -> void:
	if player_selection_manager.selected_player:
		if is_drawing:
			var mouse_pos = level.tile_map.get_local_mouse_position()
			var target_tile = level.tile_map.local_to_map(mouse_pos)
			
			if not level.check_is_tile_in_boundsv(target_tile) or level.check_is_tile_solid(target_tile):
				return
							
			if player_selection_manager.selected_player.player_path.size() >= 2 and target_tile == player_selection_manager.selected_player.player_path[-2]:
				player_selection_manager.selected_player.player_path.remove_at(player_selection_manager.selected_player.player_path.size() - 1)
			elif is_adjacent(player_selection_manager.selected_player.player_path[-1], target_tile) and player_selection_manager.selected_player.num_available_steps >= len(player_selection_manager.selected_player.player_path):
				player_selection_manager.selected_player.player_path.append(target_tile)
		
		level.draw_path(player_selection_manager.selected_player)

func _on_player_selection_changed(previous_selected_player: Player, new_selected_player: Player):
	level.free_tile(new_selected_player.starting_tile)
	#if previous_selected_player:
		#if len(previous_selected_player.player_path) > 1:
			#level.occupy_tile(previous_selected_player.player_path[-1])
			#level.free_tile(previous_selected_player.starting_tile)
	
