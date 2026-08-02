extends Node2D

var grid: AStarGrid2D = AStarGrid2D.new()
@onready var tile_map: TileMapLayer = $TileMap

var selected_player: Player
var confirmed_player_moves: int = 0

func _ready() -> void:
	setup_grid()
	connect_to_signals()
	
	for player in get_tree().get_nodes_in_group("Player"):
		player.starting_tile = tile_map.local_to_map(tile_map.to_local(player.global_position))

func connect_to_signals():
	Signals.set_selected_player.connect(set_selected_player)
	Signals.deselect_player.connect(func(): selected_player = null)

func set_selected_player(new_selected_player: Player):
	selected_player = new_selected_player

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
			
@onready var path_line: Line2D = $Path_Line
var start_tile: Vector2i = Vector2i(0,0)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_preview()
	if Input.is_action_just_pressed("player_move_confirm") and selected_player:
		if not selected_player.is_moving:
			confirm_player_move()
	if Input.is_action_just_pressed("move_confirm") and confirmed_player_moves > 0:
		Signals.move_player.emit(tile_map)

func update_preview() -> void:
	if selected_player:
		var mouse_pos = tile_map.get_local_mouse_position()
		var target_tile = tile_map.local_to_map(mouse_pos)
		
		if grid.is_in_boundsv(target_tile) and not grid.is_point_solid(target_tile):
			var path = grid.get_id_path(selected_player.starting_tile, target_tile)
			draw_path(path)
		else:
			path_line.points = [] 

func draw_path(path_tiles: Array[Vector2i]) -> void:
	var points: PackedVector2Array = []
	for tile in path_tiles:
		points.append(tile_map.map_to_local(tile))
	path_line.points = points

func confirm_player_move() -> void:
	var mouse_pos = tile_map.get_local_mouse_position()
	var target_tile = tile_map.local_to_map(mouse_pos)
	
	if grid.is_in_boundsv(target_tile) and not grid.is_point_solid(target_tile):
		var path = grid.get_id_path(selected_player.starting_tile, target_tile)
		if path.size() > 0:
			selected_player.set_player_path(path)
			confirmed_player_moves += 1
			print(confirmed_player_moves)
		
