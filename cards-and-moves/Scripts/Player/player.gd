extends Node2D
class_name Player

var starting_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2i]

func _ready() -> void:
	Signals.move_player.connect(move)

func set_player_path(new_path: Array[Vector2i]):
	player_path = new_path

func move(tile_map: TileMapLayer):
	is_moving = true
	var tween: Tween = create_tween()
	for tile in player_path:
		var world_position = tile_map.map_to_local(tile)
		tween.tween_property(self, "global_position", world_position, 0.2)
	await tween.finished
	is_moving = false
	starting_tile = tile_map.local_to_map(tile_map.to_local(self.global_position))


func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = true
		Signals.set_selected_player.emit(self)
