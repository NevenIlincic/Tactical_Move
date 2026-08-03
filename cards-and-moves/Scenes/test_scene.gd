extends Node2D

var grid: AStarGrid2D = AStarGrid2D.new()
@onready var tile_map: TileMapLayer = $TileMap

var selected_player: Player
var confirmed_player_moves: int = 0

var list_occupied_tiles: Array[Vector2i]

var players: Array[Node]
var num_finished_player_turns: int = 0

var current_state: State

func _ready() -> void:
	players = get_tree().get_nodes_in_group("Player")
	for player in players:
		var starting_tile: Vector2i = tile_map.local_to_map(tile_map.to_local(player.global_position))
		player.starting_tile = starting_tile
		player.player_path.append(starting_tile)
		list_occupied_tiles.append(starting_tile)
		
	setup_grid()
	connect_to_signals()

var current_mouse_tile_position: Vector2i

func set_occupied_tiles_list():
	list_occupied_tiles.clear()
	for player in players:
		var starting_tile: Vector2i = tile_map.local_to_map(tile_map.to_local(player.global_position))
		list_occupied_tiles.append(starting_tile)
		
func connect_to_signals():
	Signals.set_selected_player.connect(set_selected_player)
	Signals.deselect_player.connect(_on_deselect_player)
	Signals.player_move_finished.connect(check_is_turn_finished)

func _on_deselect_player():
	selected_player.is_selected = false
	selected_player = null
	draw_path([])

func check_is_turn_finished():
	num_finished_player_turns += 1
	if num_finished_player_turns == len(players):
		num_finished_player_turns = 0
		print("ZAVRSEN POTEZ!")

func set_selected_player(new_selected_player: Player):
	if selected_player:
		selected_player.is_selected = false
		selected_player.player_sprite.modulate.a = 1.0
		#if len(selected_player.player_path) == 1:
		grid.set_point_solid(selected_player.player_path[-1], true)
	selected_player = new_selected_player
	grid.set_point_solid(selected_player.starting_tile, false)

func setup_grid():
	grid.region = Rect2i(Vector2i.ZERO, tile_map.get_used_rect().size)
	grid.cell_size = tile_map.tile_set.tile_size
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	
	for cell in tile_map.get_used_cells():
		var tile_data = tile_map.get_cell_tile_data(cell)
		if tile_data.get_custom_data("solid"):
			grid.set_point_solid(cell, true)
			
	for tile in list_occupied_tiles:
		grid.set_point_solid(tile, true)
		
			
@onready var path_line: Line2D = $Path_Line
var start_tile: Vector2i = Vector2i(0,0)

var is_drawing: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_preview()
	
	if Input.is_action_just_pressed("move_confirm"):
		Signals.move_player.emit(tile_map)
	if Input.is_action_pressed("drawing"):
		if selected_player:
			is_drawing = true
	else:
		if selected_player:
			is_drawing = false

	if Input.is_action_pressed("rotate_player") and selected_player:
		selected_player.look_at(get_global_mouse_position())
	
			#selected_player.player_path.slice(0,1)
	if Input.is_action_just_pressed("reset_path") and selected_player:
		if len(selected_player.player_path) > 1:
			grid.set_point_solid(selected_player.starting_tile, true)
			grid.set_point_solid(selected_player.player_path[-1], false)
			selected_player.player_path = selected_player.player_path.slice(0, 1)
		draw_path([])
func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var diff = (a - b).abs()
	return (diff == Vector2i(1, 0)) or (diff == Vector2i(0, 1))

func update_preview() -> void:
	if selected_player:
		if is_drawing:
			var mouse_pos = tile_map.get_local_mouse_position()
			var target_tile = tile_map.local_to_map(mouse_pos)
			
			if not grid.is_in_boundsv(target_tile) or grid.is_point_solid(target_tile):
				return
			
			#var path = selected_player.player_path
			
			if selected_player.player_path.size() >= 2 and target_tile == selected_player.player_path[-2]:
				selected_player.player_path.remove_at(selected_player.player_path.size() - 1)
			elif is_adjacent(selected_player.player_path[-1], target_tile) and selected_player.num_available_steps + 1 >= len(selected_player.player_path):
				selected_player.player_path.append(target_tile)
		
		draw_path(selected_player.player_path)
func draw_path(path_tiles: Array[Vector2i]) -> void:
	var points: PackedVector2Array = []
	var drawed_steps: int = -1
	for tile in path_tiles:
		if drawed_steps <= selected_player.num_available_steps:
			drawed_steps += 1
			points.append(tile_map.map_to_local(tile))
	path_line.points = points
	if selected_player:
		selected_player.num_steps_to_do = len(path_line.points) - 1


	
