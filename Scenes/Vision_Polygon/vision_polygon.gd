class_name PlayerVisionPolygon extends Polygon2D

var soldier: Soldier

func set_soldier(player: Soldier):
	soldier = player
	soldier.vision_polygon.update_polygon_points.connect(_update_points)

func _update_points(new_points: PackedVector2Array, new_position: Vector2, new_rotation: float):
	polygon = new_points
	global_position = new_position
	rotation = new_rotation
