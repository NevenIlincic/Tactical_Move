extends Node2D 
class_name Level

var grid: AStarGrid2D = AStarGrid2D.new()
@onready var tile_map: TileMapLayer = $TileMap

var selected_player: Player
var confirmed_player_moves: int = 0

var list_occupied_tiles: Array[Vector2i]

var players: Array[Player]
var num_finished_player_turns: int = 0

var current_state: State

func _ready() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player is Player:
			var starting_tile: Vector2i = tile_map.local_to_map(tile_map.to_local(player.global_position))
			player.starting_tile = starting_tile
			players.append(player)
		
	setup_grid()
	connect_to_signals()
	current_state = PlayerSetMoveState.new([self, players])

func get_alive_players() -> Array[Player]:
	return players

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
	Signals.player_move_finished.connect(check_is_turn_finished)

#func _on_deselect_player():
	#selected_player.is_selected = false
	#selected_player = null
	#draw_path([])

func check_is_turn_finished():
	num_finished_player_turns += 1
	if num_finished_player_turns == len(players):
		num_finished_player_turns = 0
		print("ZAVRSEN POTEZ!")

#func set_selected_player(new_selected_player: Player):
	##if selected_player:
		##selected_player.is_selected = false
		##selected_player.player_sprite.modulate.a = 1.0
		###if len(selected_player.player_path) == 1:
		##grid.set_point_solid(selected_player.player_path[-1], true)
	#selected_player = new_selected_player
	##grid.set_point_solid(selected_player.starting_tile, false)

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
