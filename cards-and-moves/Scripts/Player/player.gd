extends Node2D
class_name Player

var starting_tile: Vector2i
var target_tile: Vector2i
var is_moving: bool = false
var is_selected: bool = false

var player_path: Array[Vector2i]
@onready var player_sprite: Sprite2D = $Player_Sprite

#PLAYER MOVES
var num_available_steps: int = 4
var num_steps_to_do: int = 0

#VISION
@export var max_range := 300.0
@export var fov_degrees := 90.0
@export var ray_count := 30
@export var wall_collision_mask := 1  # set to whatever physics layer your walls use

@onready var vision_polygon: Polygon2D = $Vision_Polygon


var rays: Array[RayCast2D] = []
var facing_angle := 0 # radians, 0 = facing right

func _ready() -> void:
	Signals.move_player.connect(move)
	setup_vision_rays()
func _physics_process(delta: float) -> void:
	update_vision()


func setup_vision_rays() -> void:
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	for i in ray_count:
		var t = float(i) / (ray_count - 1)
		var angle = -half_fov + t * (2 * half_fov)
		var ray = RayCast2D.new()
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.collision_mask = wall_collision_mask
		ray.enabled = true
		add_child(ray)
		rays.append(ray)


func update_vision() -> void:
	var points: PackedVector2Array = [Vector2.ZERO]  # origin (player position)
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	
	for i in rays.size():
		var t = float(i) / (rays.size() - 1)
		var angle = facing_angle - half_fov + t * (2 * half_fov)
		var ray = rays[i]
		
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			points.append(ray.to_local(ray.get_collision_point()))
		else:
			points.append(ray.target_position)
	
	vision_polygon.polygon = points

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
			player_sprite.modulate.a = 0.5
			Signals.set_selected_player.emit(self)
		else:
			player_sprite.modulate.a = 1.0
			Signals.deselect_player.emit()
