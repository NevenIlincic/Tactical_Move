extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2i]
@onready var player_sprite: Sprite2D = $Player_Sprite

#PLAYER MOVES
var num_available_steps: int = 50
var num_steps_to_do: int = 0

#VISION (FOW)
@onready var vision_polygon: PlayerVision = $Vision_Polygon


var rays: Array[RayCast2D] = []
var facing_angle := 0 # radians, 0 = facing right

func _ready() -> void:
	Signals.move_player.connect(move)
	vision_polygon.setup_vision_rays()
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()


func set_player_path(new_path: Array[Vector2i]):
	player_path = new_path

func move(tile_map: TileMapLayer):
	num_available_steps -= num_steps_to_do
	if len(player_path) != 0:
		is_moving = true
		var tween: Tween = create_tween()
		for tile in player_path:
			var world_position = tile_map.map_to_local(tile)
			tween.tween_property(self, "global_position", world_position, 0.2)
		await tween.finished
		player_path.clear()
		is_moving = false
		starting_tile = tile_map.local_to_map(tile_map.to_local(self.global_position))
		player_path.append(starting_tile)
		
func check_has_player_finished_move():
	if not is_moving:
		Signals.player_move_finished.emit()


func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = !is_selected
		if is_selected:
			Signals.set_selected_player.emit(self)
		else:
			Signals.deselect_player.emit()
