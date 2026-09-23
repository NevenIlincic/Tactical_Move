class_name PlayerVisionPolygon extends Polygon2D

var soldier: Soldier
var _last_position: Vector2
var _last_rotation: float

func _ready() -> void:
	Signals.enemy_soldier_killed.connect(_on_soldier_killed)

func set_soldier(player: Soldier):
	soldier = player
	soldier.vision_polygon.update_polygon_points.connect(_update_points)
	soldier.vision_polygon.update_vision()
func _update_points(new_points: PackedVector2Array, new_position: Vector2, new_rotation: float):
	polygon = new_points
	global_transform = Transform2D(new_rotation, new_position)

func _on_soldier_killed(enemy_killed: Soldier, killed_by: Soldier):
	if Signals.enemy_soldier_killed.is_connected(_on_soldier_killed):
		if enemy_killed.soldier_id == soldier.soldier_id:
			Signals.enemy_soldier_killed.disconnect(_on_soldier_killed)
			queue_free()
