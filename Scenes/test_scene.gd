extends Node2D 
class_name Level

var grid: AStarGrid2D = AStarGrid2D.new()
@onready var tile_map: TileMapLayer = $TileMap

var selected_player: Player
var confirmed_player_moves: int = 0

var list_occupied_tiles: Array[Vector2i]

var players: Dictionary = {} #Player
var enemies: Dictionary = {} #Enemy
var num_finished_player_turns: int = 0

var current_state: State

var cover_points: Array

func _ready() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player is Player:
			players[player] = true
	cover_points = get_tree().get_nodes_in_group("a_star_point")

	setup_grid()
	connect_to_signals()
	current_state = PlayerSetMoveState.new([self])

func _physics_process(delta: float) -> void:
	VisionManager.handle_enemy_visibility(delta)
	current_state._physics_process(delta)

func get_alive_players() -> Dictionary:
	var alive_players: Dictionary = {}
	for player in get_tree().get_nodes_in_group("Player"):
		alive_players[player] = true
	return alive_players
	
func get_alive_enemies() -> Dictionary:
	return enemies

func get_alive_soldiers() -> Dictionary:
	var alive_soldiers: Dictionary = {}
	for soldier in get_tree().get_nodes_in_group("soldier"):
		alive_soldiers[soldier] = true
	return alive_soldiers

func set_level_state(new_state: State):
	if current_state:
		current_state.queue_free()
	current_state = new_state

func set_occupied_tiles_list():
	list_occupied_tiles.clear()
	for player in players:
		var starting_tile: Vector2i = tile_map.local_to_map(tile_map.to_local(player.global_position))
		list_occupied_tiles.append(starting_tile)
		
func connect_to_signals():
	pass

func setup_grid():
	grid.region = tile_map.get_used_rect()
	grid.cell_size = tile_map.tile_set.tile_size
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	
	for cell in tile_map.get_used_cells():
		var tile_data = tile_map.get_cell_tile_data(cell)
		if tile_data.get_custom_data("solid"):
			grid.set_point_solid(cell, true)
			
	#for tile in list_occupied_tiles:
		#grid.set_point_solid(tile, true)


			
@onready var path_line: Line2D = $Path_Line
var start_tile: Vector2i = Vector2i(0,0)

var is_drawing: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	current_state._unhandled_input(event)
	
func add_point_to_path(point: Vector2) -> void:
	path_line.add_point(point)
func reset_path():
	path_line.points = []

func free_tile(tile: Vector2i):
	grid.set_point_solid(tile, false)
func occupy_tile(tile: Vector2i):
	grid.set_point_solid(tile, true)	

func check_is_tile_in_boundsv(tile: Vector2i):
	return grid.is_in_boundsv(tile) 
func check_is_tile_solid(tile: Vector2i):
	return grid.is_point_solid(tile)
