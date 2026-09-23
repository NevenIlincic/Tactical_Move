class_name PlayerVisionPolygon extends Polygon2D

var soldier: Soldier
var _last_position: Vector2
var _last_rotation: float

func set_soldier(player: Soldier):
	soldier = player
	soldier.vision_polygon.update_polygon_points.connect(_update_points)

func _update_points(new_points: PackedVector2Array, new_position: Vector2, new_rotation: float):
	polygon = new_points
	global_transform = Transform2D(new_rotation, new_position)
